using LiteDB;
using JsonSerializer = System.Text.Json.JsonSerializer;
using JsonSerializerOptions = System.Text.Json.JsonSerializerOptions;

if (args.Length < 1)
{
    Console.WriteLine("LiteDB Universal Reader - Reads LiteDB v4 and v5 files");
    Console.WriteLine("Usage: LiteDbReader5 <db-path> [collection] [limit]");
    Console.WriteLine("       LiteDbReader5 <db-path> --list       (list collections)");
    Console.WriteLine("       LiteDbReader5 <db-path> --raw        (raw binary text extraction)");
    Console.WriteLine("Example: LiteDbReader5 data.db MenuHead 10");
    return 1;
}

var dbPath = args[0];

if (!File.Exists(dbPath))
{
    Console.Error.WriteLine($"Database file not found: {dbPath}");
    return 1;
}

// Detect format from header
var header = File.ReadAllBytes(dbPath).Take(100).ToArray();
var headerText = System.Text.Encoding.ASCII.GetString(header);
var isV5Header = headerText.Contains("This is a LiteDB file");
Console.WriteLine($"// File: {Path.GetFileName(dbPath)} ({new FileInfo(dbPath).Length} bytes)");
Console.WriteLine($"// Header signature: {(isV5Header ? "LiteDB v5" : "LiteDB v4 or earlier")}");

// Raw binary extraction mode
if (args.Length >= 2 && args[1] == "--raw")
{
    Console.WriteLine("// Mode: Raw binary text extraction");
    Console.WriteLine("// Extracting readable strings from database file...");
    Console.WriteLine();
    ExtractRawStrings(dbPath);
    return 0;
}

// Try multiple connection strategies
string[] connectionStrings = new[]
{
    $"Filename={dbPath};ReadOnly=true",
    $"Filename={dbPath};ReadOnly=true;Connection=direct",
    $"Filename={dbPath};ReadOnly=true;Connection=shared",
    $"Filename={dbPath};Connection=direct",
    $"Filename={dbPath};Upgrade=true;ReadOnly=true",
};

Exception? lastException = null;

foreach (var connStr in connectionStrings)
{
    try
    {
        using var db = new LiteDatabase(connStr);
        Console.WriteLine($"// Connected with: {connStr}");

        // List collections mode
        if (args.Length == 1 || (args.Length >= 2 && args[1] == "--list"))
        {
            var collections = db.GetCollectionNames().ToList();
            Console.WriteLine($"// Collections ({collections.Count}):");
            foreach (var col in collections)
            {
                var count = db.GetCollection(col).Count();
                Console.WriteLine($"//   - {col}: {count} documents");
            }
            return 0;
        }

        // Query collection
        var collectionName = args[1];
        var limit = args.Length > 2 ? int.Parse(args[2]) : 100;

        var collection = db.GetCollection(collectionName);
        var totalCount = collection.Count();
        var documents = collection.FindAll().Take(limit).ToList();

        Console.WriteLine($"// Collection: {collectionName}, Total: {totalCount}, Showing: {documents.Count}");

        foreach (var doc in documents)
        {
            var json = JsonSerializer.Serialize(BsonToObject(doc), new JsonSerializerOptions
            {
                WriteIndented = true
            });
            Console.WriteLine(json);
            Console.WriteLine("---");
        }

        return 0;
    }
    catch (Exception ex)
    {
        lastException = ex;
        // Try next connection string
    }
}

// All connection strategies failed — fall back to raw extraction
Console.Error.WriteLine($"// WARNING: All LiteDB connection strategies failed.");
Console.Error.WriteLine($"// Last error: {lastException?.Message}");
Console.Error.WriteLine($"// Falling back to raw binary text extraction...");
Console.WriteLine();
ExtractRawStrings(dbPath);
return 0;

static void ExtractRawStrings(string filePath)
{
    var bytes = File.ReadAllBytes(filePath);
    
    Console.WriteLine("// === DETECTED STRINGS (min length 4) ===");
    var currentString = new System.Text.StringBuilder();
    var detectedStrings = new HashSet<string>();
    var categorized = new Dictionary<string, List<string>>
    {
        ["FIELD"] = new(),
        ["IDENTIFIER"] = new(),
        ["TIMESTAMP"] = new(),
        ["VALUE"] = new(),
        ["OTHER"] = new()
    };

    foreach (var b in bytes)
    {
        if (b >= 32 && b <= 126) // Printable ASCII
        {
            currentString.Append((char)b);
        }
        else
        {
            if (currentString.Length >= 4)
            {
                var str = currentString.ToString().Trim();
                if (str.Length >= 4 && !str.All(c => c == '.' || c == ' ') && detectedStrings.Add(str))
                {
                    CategorizeString(str, categorized);
                }
            }
            currentString.Clear();
        }
    }

    // Final string
    if (currentString.Length >= 4)
    {
        var str = currentString.ToString().Trim();
        if (str.Length >= 4 && !str.All(c => c == '.' || c == ' ') && detectedStrings.Add(str))
        {
            CategorizeString(str, categorized);
        }
    }

    // Output categorized results
    foreach (var (category, strings) in categorized.Where(kv => kv.Value.Count > 0))
    {
        Console.WriteLine($"\n// --- {category} ({strings.Count}) ---");
        foreach (var s in strings.Take(200)) // Cap output
        {
            Console.WriteLine($"  {s}");
        }
        if (strings.Count > 200)
            Console.WriteLine($"  ... and {strings.Count - 200} more");
    }

    Console.WriteLine($"\n// Total unique strings found: {detectedStrings.Count}");
}

static void CategorizeString(string str, Dictionary<string, List<string>> categorized)
{
    // Field names (likely BSON keys)
    if (str.Length <= 40 && (
        str.Contains("Id") || str.Contains("_id") || str.Contains("Date") ||
        str.Contains("Name") || str.Contains("Type") || str.Contains("Channel") ||
        str.Contains("Context") || str.Contains("Order") || str.Contains("Menu") ||
        str.Contains("Last") || str.Contains("Update") || str.Contains("Head") ||
        str.Contains("Status") || str.Contains("Version") || str.Contains("Count") ||
        str.Contains("Created") || str.Contains("Modified") || str.Contains("Identifier")))
    {
        categorized["FIELD"].Add(str);
    }
    // Identifiers (underscore-separated like ContextIdentifier values)
    else if (str.Contains("_") && str.Count(c => c == '_') >= 2 && str.Length >= 6)
    {
        categorized["IDENTIFIER"].Add(str);
    }
    // Timestamps or date-like
    else if ((str.Contains("/") || str.Contains("-")) && str.Contains(":") && str.Length >= 10)
    {
        categorized["TIMESTAMP"].Add(str);
    }
    // Numeric values
    else if (str.All(c => char.IsDigit(c) || c == '.' || c == '-'))
    {
        categorized["VALUE"].Add(str);
    }
    // Everything else
    else if (str.Length >= 5)
    {
        categorized["OTHER"].Add(str);
    }
}

static object? BsonToObject(BsonValue value)
{
    return value.Type switch
    {
        BsonType.Null => null,
        BsonType.Int32 => value.AsInt32,
        BsonType.Int64 => value.AsInt64,
        BsonType.Double => value.AsDouble,
        BsonType.Decimal => value.AsDecimal,
        BsonType.String => value.AsString,
        BsonType.Boolean => value.AsBoolean,
        BsonType.DateTime => value.AsDateTime.ToString("o"),
        BsonType.Guid => value.AsGuid.ToString(),
        BsonType.ObjectId => value.AsObjectId.ToString(),
        BsonType.Array => value.AsArray.Select(BsonToObject).ToList(),
        BsonType.Document => value.AsDocument.ToDictionary(k => k.Key, v => BsonToObject(v.Value)),
        _ => value.ToString()
    };
}
