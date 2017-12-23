import {grpc} from "grpc-web-client";

import {CustomerService} from "../../protocol/customer_service_pb_service.js";
import {RequestType, Person} from "../../protocol/customer_service_pb.js";

function ListPersonCall() {
  // テストなのでまずpersonを追加しておく
  const person = new Person();
  person.setName("akira");
  person.setAge(28);
  grpc.invoke(CustomerService.AddPerson, {
    request: person,
    host: "http://localhost:9090",
    onMessage: (message) => {
      console.log("onMessage", message.toObject());
    },
    onEnd: (code, msg, trailers) => {
      console.log("onEnd", code, msg, trailers);
    }
  });

  // personが追加されているかを確認する
  const req = new RequestType();

  grpc.invoke(CustomerService.ListPerson, {
    request: req,
    host: "http://localhost:9090",
    onMessage: (message) => {
      console.log("onMessage", message.toObject());
      alert(message.getName());
    },
    onEnd: (code, msg, trailers) => {
      console.log("onEnd", code, msg, trailers);
    }
  });
}

// ちゃんと動けば引数の文字列がダイアログに出てくる
ListPersonCall();
