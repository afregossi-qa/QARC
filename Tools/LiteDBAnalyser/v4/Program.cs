using LiteDB;
using JsonSerializer = System.Text.Json.JsonSerializer;
using JsonSerializerOptions = System.Text.Json.JsonSerializerOptions;

if (args.Length < 1)
{
    Console.WriteLine("LiteDB v4 Reader - Query LiteDB v4 files and export to JSON");
    Console.WriteLine("Usage: LiteDbReader <db-path> [collection] [limit]");
    Console.WriteLine("       LiteDbReader <db-path> --list    (list collections)");
    Console.WriteLine("Example: LiteDbReader data.db Checks 10");
    return 1;
}

var dbPath = args[0];

if (!File.Exists(dbPath))
{
    Console.Error.WriteLine($"Database file not found: {dbPath}");
    return 1;
}

Console.WriteLine($"// File: {Path.GetFileName(dbPath)} ({new FileInfo(dbPath).Length} bytes)");
Console.WriteLine($"// Reader: LiteDB v4 ({typeof(LiteDatabase).Assembly.GetName().Version})");

// Try multiple connection strategies for v4
string[] connectionStrings = new[]
{
    $"Filename={dbPath};Mode=ReadOnly",
    $"Filename={dbPath};Journal=false;Mode=ReadOnly",
    $"Filename={dbPath};Mode=Shared",
    $"Filename={dbPath}",
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
    }
}

Console.Error.WriteLine($"// ERROR: All v4 connection strategies failed.");
Console.Error.WriteLine($"// Last error: {lastException?.Message}");
Console.Error.WriteLine("// Try LiteDbReader5 (v5) instead, or use --raw mode on LiteDbReader5.");
return 1;

static object? BsonToObject(BsonValue value)
{
    return value.Type switch
    {
        BsonType.Null => null,
        BsonType.Int32 => value.AsInt32,
        BsonType.Int64 => value.AsInt64,
        BsonType.Double => value.AsDouble,
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
