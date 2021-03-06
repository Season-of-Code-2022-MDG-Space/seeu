import 'package:flutter/material.dart';
import 'package:seeu/helper/constants.dart';
import 'package:seeu/services/database.dart';
import 'package:seeu/view/talkingToSchedule.dart';

class Chatroom extends StatefulWidget {
  final String theOtherUser;
  final String chatRoomId;
  const Chatroom({ Key? key , required this.chatRoomId , required this.theOtherUser}): super(key: key);

  @override
  State<Chatroom> createState() => _ChatroomState();
}

class _ChatroomState extends State<Chatroom> {

  TextEditingController messageTextEditingController = TextEditingController();
  DatabaseMethods databaseMethods = DatabaseMethods();

  Stream? chatMessagesStream;
  bool meallows = false;
  bool theOtherUserallows = false;

  getShareableSchedulerConsentInfo(String chatRoomId , String user){
    databaseMethods.getUserConsentOnSharingSchedule(chatRoomId).then((val){
      theOtherUserallows = val.data()[user+"Allows"];
      print(theOtherUserallows);
      meallows = val.data()[Constants.myName+"Allows"];
    });
  }
   @override
  void initState() {
    databaseMethods.getChatMessagesFromDatabase(widget.chatRoomId).then((value){
      
      setState(() {
        chatMessagesStream = value;
      });
    });
    setState(() {
      getShareableSchedulerConsentInfo(widget.chatRoomId , widget.theOtherUser);
    });
    super.initState();
  }

  // ignore: non_constant_identifier_names
  Widget ChatMessageList(){
    return StreamBuilder<dynamic>(
      stream: chatMessagesStream,
      builder: (context , AsyncSnapshot snapshot){
        if(snapshot.data != null){
           return ListView.builder(
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context , index){
            return ChatMessageTile(message: snapshot.data.docs[index]["Message"] , iAmSender: Constants.myName==snapshot.data.docs[index]["SentBy"]);
          });
        }else{
          return const Center(child: CircularProgressIndicator(),);
        }
       
      });
  }

  sendMessage(){
    if(messageTextEditingController.text.isNotEmpty){
      Map<String, dynamic> messageMap = {
      "Message" : messageTextEditingController.text,
      "SentBy" : Constants.myName,
      "TimeStamp" : DateTime.now().microsecondsSinceEpoch
    };
    databaseMethods.addChatMessageToDatabase(widget.chatRoomId, messageMap);
    messageTextEditingController.text = "";
    } 
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children:  [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.teal[700],
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(widget.theOtherUser.substring(0,1).toUpperCase() , 
            style: const TextStyle(
              color: Colors.white , 
              fontSize: 20 , fontWeight: 
              FontWeight.w400 , 
              fontStyle: FontStyle.italic)
              ),
          ),
          Text(widget.theOtherUser, style: const TextStyle(color: Colors.white , fontSize: 22 , fontWeight: FontWeight.w400))
        ]),
        actions: [
          GestureDetector(
            onTap: (){
              setState(() {
                databaseMethods.updateUserConsentOnSharingSchedule(widget.chatRoomId, meallows);
                meallows = !meallows;
              });

              if(meallows && theOtherUserallows == true){
                Navigator.push(context, MaterialPageRoute(builder: (context)=> TalkingtoSchedule(talkingTo : widget.theOtherUser)));
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 7.5),
              height: 30,
              width: 40,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.circular(30)),
              child: meallows && theOtherUserallows ? 
              const Icon(Icons.schedule_rounded , color: Colors.teal) : 
                (meallows || theOtherUserallows ?
                const Icon(Icons.schedule_rounded, color: Colors.blue) :
                  const Icon(Icons.schedule_rounded, color: Colors.red) 
                )      
             ),
          )
        ],) ,
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 70),
            child: ChatMessageList()),
  
          Container(
            
            alignment : Alignment.bottomCenter,
            padding : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

            child: Row(
              children: [
                    Expanded (
                      child: Container(
                  
                        padding: const EdgeInsets.symmetric(horizontal: 6 , vertical: 3.5),
                        decoration: BoxDecoration(
                          color: Colors.teal[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: messageTextEditingController,
                          decoration: InputDecoration(
                            hintText: "Message...",
                            hintStyle: TextStyle(
                              color: Colors.teal[400],
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                            
                            border: InputBorder.none
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                  onTap: (){
                    sendMessage();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal[200],
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(Icons.send_rounded, color: Colors.teal[900] , size: 26,)
                  ),
                ),
                
              ],
            ),
          )
        ],
      ),
      
    );
  }
}

class ChatMessageTile extends StatelessWidget {
  final String message;
  final bool iAmSender;
  const ChatMessageTile({ Key? key , required this.message , required this.iAmSender}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
       margin : const EdgeInsets.symmetric(vertical : 6),
        width: MediaQuery.of(context).size.width,
        alignment: (iAmSender) ? Alignment.bottomRight : Alignment.bottomLeft,
      child: Container( 
        padding: const EdgeInsets.symmetric(horizontal: 12 , vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: iAmSender ? [
           const Color(0xFF4DB6AC), 
           const Color(0xFF80DEEA) ] :
           [const Color(0xFFAED581),
           const Color(0xFF81C784)]
          ),
          borderRadius: iAmSender ?
          (const BorderRadius.only( 
            topRight: Radius.circular(24) , 
            topLeft: Radius.circular(24),
            bottomLeft: Radius.circular(24)
          )) : 
          (const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ))
            
        ),
        
        child: Text(
          message ,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w400,
          ), ),
        
      ),
    );
  }
}