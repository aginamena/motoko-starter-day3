import Type "type";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";

actor StudentWall {
  type Message = Type.Message;
  type Content = Type.Content;
  type Survey = Type.Survey;
  type Answer = Type.Answer;

  let wall = Buffer.Buffer<Message>(0);
  public shared func write(c : Content) : async Nat {
    let message : Message = {
      id = wall.size();
      field = c;
    };
    wall.add(message);
    return message.id;
  };
  public shared func clean(id : Nat) : async Result.Result<(), Text> {
    if (id >= wall.size()) {
      return #err("Invalid message id");
    };
    let message = wall.remove(id);
    #ok();
  };
  public shared func vote(messageId : Nat, answerId : Nat) : async Result.Result<(), Text> {
    if (messageId >= wall.size()) {
      return #err("Invalid message id");
    };
    let message : Message = wall.get(messageId);
    switch (message.field) {
      //dynamically getting the value of the variant. The field value can either be Text, Image or Servey
      case (#Text(textValue)) return #err("Invalid answerId");
      case (#Image(blobValue)) return #err("Invalid answerId");
      case (#Survey(surveyValue)) {
        if (answerId < surveyValue.answers.size()) { return #ok() };
        return #err("Invalid answerId");
      };
    };

  };
  public shared query func getMessage(id : Nat) : async Result.Result<Message, Text> {
    if (id >= wall.size()) {
      return #err("Invalid message id");
    };
    #ok(wall.get(id));
  };
  public shared query func getAllMessages() : async [Message] {
    Buffer.toArray(wall);
  };
  public shared query func getAllImages() : async [Blob] {
    let result = Buffer.Buffer<Blob>(0);
    Buffer.iterate<Message>(
      wall,
      func(message) {
        switch (message.field) {
          //dynamically getting the value of the variant
          case (#Image(value)) result.add(value);
          case (#Text(textValue)) {};
          case (#Survey(surveyValue)) {};
        };
      },
    );
    Buffer.toArray(result);
  };
  public shared query func getAllSurveys() : async [Survey] {
    let result = Buffer.Buffer<Survey>(0);
    Buffer.iterate<Message>(
      wall,
      func(message) {
        switch (message.field) {
          //dynamically getting the value of the variant
          case (#Image(value)) {};
          case (#Text(textValue)) {};
          case (#Survey(surveyValue)) {
            result.add(surveyValue);
          };
        };
      },
    );
    Buffer.toArray(result);
  };
};
