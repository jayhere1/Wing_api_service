bring cloud;
bring util;
bring redis;
bring "@cdktf/provider-aws" as aws;
// bring "@aws-cdk-lib" as cdk;


enum FileAttributeType{
  String,
  File,
  Number
}

struct FileAttribute {
  type: FileAttributeType;
  value:Json;
}

let checkFile = (input_file: FileAttribute):FileAttribute =>{
return input_file;
};

class AddDocs_DB {

    db: redis.Redis;
    counter: cloud.Counter;

    init() {
        this.db = new redis.Redis();
        this.counter = new cloud.Counter();
 
    }

    inflight _add(id: str, j: Json): str {
        this.db.set(id , Json.stringify(j));
        this.db.sadd("docs", id);
        return id;
    }
  }

class StoreData{
  api_bucket:cloud.Bucket;
  api:cloud.Api;
  docsDB: AddDocs_DB;
  init(docsDB: AddDocs_DB){

  this.docsDB = docsDB;
  this.api = new cloud.Api();

  this.api_bucket = new cloud.Bucket() as "Document Store";

  this.api.post("/doc", inflight (req: cloud.ApiRequest): cloud.ApiResponse => {
  let documentId = req.headers;
  let documentBody = req.body;

  // Store the document in the bucket
  let key = "origin/${documentId}.txt";
  this.api_bucket.putJson(key, documentBody);

  log("Document stored successfully");

 
});
    this.api.options("/doc", inflight(req: cloud.ApiRequest): cloud.ApiResponse => {
        return cloud.ApiResponse {
            headers: {
                "Access-Control-Allow-Headers" : "Content-Type",
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "OPTIONS,POST,GET"
            },
            status: 200
        };
    });
  }
  

}
    

let app = new AddDocs_DB();
let appapi = new StoreData(app);

// --- tests ---

// test "Test Checkfile" {
//   appapi;
//   }









