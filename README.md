# OTRS-Ticket-Notification-To-MS-Teams
- Built for OTRS CE v 6.0.x
- Send ticket notification to MS Teams Channel upon ticket action. E.g: TicketQueueUpdate

		Used CPAN Module:
		
		JSON::MaybeXS; 			#yum install -y perl-JSON-MaybeXS
		LWP::UserAgent;  		#yum install -y perl-LWP-Protocol-https
		HTTP::Request::Common;	
    

1. Create incomig webhook by adding 'Incoming Webhook' app in MS Teams.Configure it, add it to specific channel and get the Webhook URL.

2. Update the Webhook Url at System Configuration > TicketMSTeams::Queue

		Queue 1 Name => MS Team Channel Webhook 1  
		Queue 2 Name => MS Team Channel Webhook 2  
		Queue 3 Name => MS Team Channel Webhook 3  
		
		Example :
		Misc => https://outlook.office.com/webhook/b30SDS10-9466-fd0c1556d9b1/IncomingWebhook/6DFGDF88  
		and so on..

3. Admin must create a new Generic Agent (GA) with option to execute custom module.

		[Mandatory][Name]: Up to you.
		[Mandatory][Event Based Execution] : Mandatory. Up to you. Example, TicketQueueUpdate for moving ticket to another queue
		[Optional][Select Ticket]: Optional. Up to you.
		[Mandatory][Execute Custom Module] : Module => Kernel::System::Ticket::Event::TicketSlack
	
		[Mandatory][Param 1 Key] : Subject   
		[Mandatory][Param 1 Value] : Text subject to be sent to the channel.
		[Mandatory][Param 2 Key] : Text1  
		[Mandatory[Param 2 Value] : Text body to be sent to the channel.
		[Optional][Param 3 Key] : Text2  
		[Optional[Param 3 Value] : Additional text body to be sent to the channel.
		
		#Support OTRS ticket TAG only. 
		#Support <OTRS_NOTIFICATION_RECIPIENT_UserFullname>, <OTRS_OWNER_UserFullname>, <OTRS_RESPONSIBLE_UserFullname> and <OTRS_CUSTOMER_UserFullname> tag.
		#Only support plain text.
  
  
[![da.png](https://i.postimg.cc/QM5MzwHX/da.png)](https://postimg.cc/94mVRxdS)
