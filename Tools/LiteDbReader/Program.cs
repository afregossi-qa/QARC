using LiteDB;
using JsonSerializer = System.Text.Json.JsonSerializer;
using JsonSerializerOptions = System.Text.Json.JsonSerializerOptions;

if (args.Length < 1)
{
    Console.WriteLine("LiteDB Reader - Query LiteDB files and export to JSON");
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

try
{
    using var db = new LiteDatabase($"Filename={dbPath};ReadOnly=true");
    
    // List collections mode
    if (args.Length == 1 || (args.Length >= 2 && args[1] == "--list"))
    {
        var collections = db.GetCollectionNames().ToList();
        Console.WriteLine($"// Database: {Path.GetFileName(dbPath)}");
        Console.WriteLine($"// Collections ({collections.Count}):");
        foreach (var col in collections)
        {
            var count = db.GetCollection(col).Count();
            Console.WriteLine($"//   - {col}: {count} documents");
        }
        return 0;
    }
    
    var collectionName = args[1];
    var limit = args.Length > 2 ? int.Parse(args[2]) : 100;
    
    var collection = db.GetCollection(collectionName);
    var documents = collection.FindAll().Take(limit).ToList();
    
    Console.WriteLine($"// Collection: {collectionName}, Count: {documents.Count}");
    
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
    Console.Error.WriteLine($"Error: {ex.Message}");
    return 1;
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
