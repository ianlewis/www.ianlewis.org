---
layout: post
title: "Protocol Buffers"
date: 2008-07-12 20:22:09 +0000
permalink: /en/protocol-buffers
blog: en
tags: tech programming python
render_with_liquid: false
---

A few days ago [Protocol Buffers](https://protobuf.dev/) was released by Google
as an open source project. Protocol Buffers is a way to generate code for
objects that can be serialized to and deserialized from the Protocol Buffers
binary format. An implementation of the Protocol Buffers compiler which reads a
`.proto` file and can output Java, Python, and C++ code. Because the format is a
binary format and the compiler can output in several languages, this would allow
for fast message passing between applications that may or may not be implemented
in the same language.

I went ahead and created two simple Java and Python applications that test
Protocol Buffers by simply creating a simple User object, prompting the user for
a nickname and e-mail and then serializing the result. I also added a command to
deserialize the output and show the contents of the reconstituted object. Here
I ran the Java program to write the Protocol Buffers data to a file and then I
run the Python program to read it.

```bash
ian@laptop:~/src/protocol-buffers-test$ make javawrite
# Write a Protocol Buffers object in Java
mkdir -p java
protoc --java_out=java/ prototest.proto
javac -classpath "java/:protobuf-java-2.0.0beta.jar" java/test.java java/prototest/Prototest.java
java -cp ".:java/:protobuf-java-2.0.0beta.jar" test write test.out
Nickname: Ian <- this is input
Email: test@test.com <- this is input

ian@laptop:~/src/protocol-buffers-test$ make javaread
# Read a Protocol Buffers object in Java
java -cp ".:java/:protobuf-java-2.0.0beta.jar" test read test.out
User
Nickname: Ian <- this is output
Email: test@test.com <- this is output
土  7月 12 19:09:33
ian@laptop:~/src/protocol-buffers-test$
```

Code available ~~here~~. Code listing follows.

Protocol Buffers file: `prototest.proto`

```proto
option java_package = "prototest";

message User {
  required string nickname = 1;
  required string emailaddress = 2;
}
```

Java program: `test.java`

```java
import prototest.*;
import com.google.protobuf.CodedInputStream;
import java.io.*;

/**
 * class test
 * Class to test protobuffer
 * @author Ian Lewis <IanLewis@member.fsf.org>
 */
public class test {

  public static void main(String[] args) {
    if (args.length < 1) {
      System.err.println("Need a command");
    } else if (args.length < 2) {
      System.err.println("Need a file name");
    } else if (args[0].equals("write")) {
      try {
        Prototest.User.Builder userbuilder = Prototest.User.newBuilder();

        BufferedReader in = new BufferedReader(new InputStreamReader(System.in));
        String nickname = new String();
        String email = new String();
        while (nickname.length() == 0) {
          System.out.print("Nickname: ");
          nickname = in.readLine();
          if (nickname.length() == 0) {
            System.err.println("Nickname is empty!");
          }
        }
        while (email.length() == 0) {
          System.out.print("Email: ");
          email = in.readLine();
          if (email.length() == 0) {
            System.err.println("Email is empty!");
          }
        }

        userbuilder.setEmailaddress(email);
        userbuilder.setNickname(nickname);

        FileOutputStream out = new FileOutputStream(new File(args[1]));
        userbuilder.build().writeTo(out);
        out.close();
      } catch (IOException ioe) {
        System.err.println(ioe.getMessage());
      }
    } else if (args[0].equals("read")) {
      try {
        FileInputStream filein = new FileInputStream(new File(args[1]));
        CodedInputStream in = CodedInputStream.newInstance(filein);
        Prototest.User user = Prototest.User.parseFrom(in);
        System.out.println("User");
        System.out.println("Nickname: "+user.getNickname());
        System.out.println("Email: "+user.getEmailaddress());
        filein.close();
      } catch (IOException ioe) {
        System.err.println(ioe.getMessage());
      }
    } else {
      System.err.println("Unknown command");
    }
  }
}
```

Python program: `test.py`

```python
import sys
import prototest_pb2

def PromptForUser(person):
  user.nickname = raw_input("Nickname: ")
  user.emailaddress = raw_input("Email: ")

def PrintUsage():
  print "Usage:", sys.argv[0], "[read/write] file"
  sys.exit(-1)

if len(sys.argv) != 3 or (sys.argv[1] != "read" and sys.argv[1] != "write"):
  PrintUsage()

user = prototest_pb2.User()

# Read
if (sys.argv[1] == "read"):
  try:
    f = open(sys.argv[2], "rb")
    user.ParseFromString(f.read())
    f.close()

    print "User"
    print "Nickname: %s" % user.nickname
    print "Email: %s" % user.emailaddress
  except IOError:
    print sys.argv[1] + ": Could not open file."
    sys.exit(-1)
elif (sys.argv[1] == "write"):
  PromptForUser(user)
  # Write
  f = open(sys.argv[2], "wb")
  f.write(user.SerializeToString())
  f.close()
else:
  PrintUsage()
```
