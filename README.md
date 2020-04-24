# OTRS-Ticket-Notification-To-MS-Teams
- Built for OTRS CE v 6.0.x
- Send a MS Teams notification to Channel upon ticket action. E.g: TicketQueueUpdate
- **Require CustomMessage API**  

1. Create incomig webhook by add Incoming Webhook app in MS Teams.Configure it, add it to specific channel and get the Webhook URL.

2. Update the Webhook Url at System Configuration > TicketMSTeams::Queue

Queue 1 Name => MS Team Channel Webhook 1  
Queue 2 Name => MS Team Channel Webhook 2  
Queue 3 Name => MS Team Channel Webhook 3  
Misc :: https://outlook.office.com/webhook/b30SDS10-9466-fd0c1556d9b1/IncomingWebhook/6DFGDF88  
and so on..

3. Admin must create a new Generic Agent (GA) with option to execute custom module.

Execute Custom Module => Module => Kernel::System::Ticket::Event::TicketMSTeams
	
[MANDATORY PARAM]

Param 1 Key => Subject   
Param 1 Value => *Text Subject to be sent to the channel.  
#Also support OTRS ticket TAG only.  
#Also support <OTRS_OWNER_UserFullname>, <OTRS_RESPONSIBLE_UserFullname> and <OTRS_CUSTOMER_UserFullname> tag.  
#Only support plain text.
	
Param 2 Key => Text1  
Param 2 Value => *Text body to be sent to the channel.  
#Also support OTRS ticket TAG only.  
#Also support <OTRS_OWNER_UserFullname>, <OTRS_RESPONSIBLE_UserFullname> and <OTRS_CUSTOMER_UserFullname> tag.  
#Only support plain text.
					 
[OPTIONAL PARAM]
	
Param 3 Key => Text2  
Param 3 Value => *Additional text to be sent to the channel.  
#Also support OTRS ticket TAG only. bold, newline must be in HTML code.  
#Also support <OTRS_NOTIFICATION_RECIPIENT_UserFullname>, <OTRS_OWNER_UserFullname>, <OTRS_RESPONSIBLE_UserFullname> and <OTRS_CUSTOMER_UserFullname> tag.


[![da.png](https://i.postimg.cc/QM5MzwHX/da.png)](https://postimg.cc/94mVRxdS)
