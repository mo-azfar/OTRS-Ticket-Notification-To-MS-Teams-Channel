# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
#Send a notification to MS Teams Channel upon ticket action. E.g: TicketQueueUpdate
package Kernel::System::Ticket::Event::TicketMSTeams;

use strict;
use warnings;

# use ../ as lib location
use File::Basename;
use FindBin qw($RealBin);
use lib dirname($RealBin);

#use SOAP::Lite;
#use Data::Dumper;
#use Fcntl qw(:flock SEEK_END);

our @ObjectDependencies = (
    'Kernel::System::Ticket',
    'Kernel::System::Log',
	'Kernel::System::Group',
	'Kernel::System::Queue',
	'Kernel::System::User',
	
);

=head1 NAME

Kernel::System::ITSMConfigItem::Event::DoHistory - Event handler that does the history

=head1 SYNOPSIS

All event handler functions for history.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $DoHistoryObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItem::Event::DoHistory');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;
    
	#my $parameter = Dumper(\%Param);
    #$Kernel::OM->Get('Kernel::System::Log')->Log(
    #    Priority => 'error',
    #    Message  => $parameter,
    #);
	
	# check needed param
    if ( !$Param{TicketID} || !$Param{New}->{Subject} || !$Param{New}->{Text1} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need TicketID || Subject || Text1 (Param and Value) for this operation',
        );
        return;
    }

    #my $TicketID = $Param{Data}->{TicketID};  ##This one if using sysconfig ticket event
	my $TicketID = $Param{TicketID};  ##This one if using GenericAgent ticket event
	my $Subject = $Param{New}->{'Subject'}; ##This one if using GenericAgent ticket event
	my $Text1 = $Param{New}->{'Text1'}; ##This one if using GenericAgent ticket event
    
	if ( defined $Param{New}->{'Text2'} ) { $Text1 = "$Text1. $Param{New}->{Text2}"; }
	
	my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
	
	# get ticket content
	my %Ticket = $TicketObject->TicketGet(
        TicketID => $TicketID ,
		UserID        => 1,
		DynamicFields => 1,
		Extended => 0,
    );
	
	return if !%Ticket;
	
	#print "Content-type: text/plain\n\n";
	#print Dumper(\%Ticket);
	
	my $LogObject     = $Kernel::OM->Get('Kernel::System::Log');
	my $UserObject = $Kernel::OM->Get('Kernel::System::User');
	my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');
	my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
	my $QueueObject = $Kernel::OM->Get('Kernel::System::Queue');
	my $GroupObject = $Kernel::OM->Get('Kernel::System::Group');
	
	#Get	queue id based on ticket queue name
	my $QueueID = $QueueObject->QueueLookup( Queue => $Ticket{Queue} );
	#Get group id based on queue id 
	my $GroupID = $QueueObject->GetQueueGroupID( QueueID => $QueueID );
	
	# prepare owner fullname based on subject tag
    if ( $Subject =~ /<OTRS_OWNER_UserFullname>/ ) {
		my %OwnerPreferences = $UserObject->GetUserData(
        UserID        => $Ticket{OwnerID},
        NoOutOfOffice => 0,
    );
	
	for ( sort keys %OwnerPreferences ) {
        $Subject =~ s/<OTRS_OWNER_UserFullname>/$OwnerPreferences{UserFullname}/g;
		}   
    }
	
	# prepare responsible fullname based on subject tag
    if ( $Subject =~ /<OTRS_RESPONSIBLE_UserFullname>/ ) {
		my %ResponsiblePreferences = $UserObject->GetUserData(
        UserID        => $Ticket{ResponsibleID},
        NoOutOfOffice => 0,
    );
	
	for ( sort keys %ResponsiblePreferences ) {
        $Subject =~ s/<OTRS_RESPONSIBLE_UserFullname>/$ResponsiblePreferences{UserFullname}/g;
		}   
    }
	
	# prepare customer fullname based on Subject tag
    if ( $Subject =~ /<OTRS_CUSTOMER_UserFullname>/ ) {
		my $FullName = $CustomerUserObject->CustomerName( UserLogin => $Ticket{CustomerUserID} );
		$Subject =~ s/<OTRS_CUSTOMER_UserFullname>/$FullName/g;
    };
	
	
	# prepare owner fullname based on Text1 tag
    if ( $Text1 =~ /<OTRS_OWNER_UserFullname>/ ) {
		my %OwnerPreferences = $UserObject->GetUserData(
        UserID        => $Ticket{OwnerID},
        NoOutOfOffice => 0,
    );
	
	for ( sort keys %OwnerPreferences ) {
        $Text1 =~ s/<OTRS_OWNER_UserFullname>/$OwnerPreferences{UserFullname}/g;
		}   
    }
	
	# prepare responsible fullname based on Text1 tag
    if ( $Text1 =~ /<OTRS_RESPONSIBLE_UserFullname>/ ) {
		my %ResponsiblePreferences = $UserObject->GetUserData(
        UserID        => $Ticket{ResponsibleID},
        NoOutOfOffice => 0,
    );
	
	for ( sort keys %ResponsiblePreferences ) {
        $Text1 =~ s/<OTRS_RESPONSIBLE_UserFullname>/$ResponsiblePreferences{UserFullname}/g;
		}   
    }
	
	# prepare customer fullname based on text1 tag
    if ( $Text1 =~ /<OTRS_CUSTOMER_UserFullname>/ ) {
		my $FullName = $CustomerUserObject->CustomerName( UserLogin => $Ticket{CustomerUserID} );
		$Text1 =~ s/<OTRS_CUSTOMER_UserFullname>/$FullName/g;
    };
	
	#change to < and > for Subject tag
	$Subject =~ s/&lt;/</ig;
	$Subject =~ s/&gt;/>/ig;	
	
	#change to < and > for text1 tag
	$Text1 =~ s/&lt;/</ig;
	$Text1 =~ s/&gt;/>/ig;	
	
	#get data based on Subject tag
	my $RecipientSubject = $Kernel::OM->Get('Kernel::System::Ticket::Event::NotificationEvent::Transport::Email')->_ReplaceTicketAttributes(
        Ticket => \%Ticket,
        Field  => $Subject,
    );
	
	#get data based on text1 tag
	my $RecipientText1 = $Kernel::OM->Get('Kernel::System::Ticket::Event::NotificationEvent::Transport::Email')->_ReplaceTicketAttributes(
        Ticket => \%Ticket,
        Field  => $Text1,
    );
	
	my $HTMLUtilsObject = $Kernel::OM->Get('Kernel::System::HTMLUtils');
	#strip all html tag 
    my $MessageSubject = $HTMLUtilsObject->ToAscii( String => $RecipientSubject );	
	my $MessageText1 = $HTMLUtilsObject->ToAscii( String => $RecipientText1 );
	
	my $HttpType = $ConfigObject->Get('HttpType');
	my $FQDN = $ConfigObject->Get('FQDN');
	my $ScriptAlias = $ConfigObject->Get('ScriptAlias');
	
	my $DateTimeObject = $Kernel::OM->Create('Kernel::System::DateTime', ObjectParams => { String   => $Ticket{Created},});
	my $DateTimeString = $DateTimeObject->Format( Format => '%Y-%m-%d %H:%M' );
	
	my $MSTeamWebhookURL;
    my %MSTeamWebhookURLs = %{ $ConfigObject->Get('TicketMSTeams::Queue') };
	
	for my $WebHookQueue ( sort keys %MSTeamWebhookURLs )   
	{
		next if $Ticket{Queue} ne $WebHookQueue;
		$MSTeamWebhookURL = $MSTeamWebhookURLs{$WebHookQueue};
        # error if queue is defined but Webhook URLis empty
        if ( !$MSTeamWebhookURL )
        {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'notice',
                Message  => "No WebhookURL defined for Queue $Ticket{Queue}"
            );
            return;
        }
  	    
		my $TicketURL = $HttpType.'://'.$FQDN.'/'.$ScriptAlias.'index.pl?Action=AgentTicketPrint;TicketID='.$TicketID;	
		
		# For Asynchronous sending
		my $TaskName = substr "Recipient".rand().$MSTeamWebhookURL, 0, 255;
		
		# instead of direct sending, we use task scheduler
		my $TaskID = $Kernel::OM->Get('Kernel::System::Scheduler')->TaskAdd(
			Type                     => 'AsynchronousExecutor',
			Name                     => $TaskName,
			Attempts                 =>  1,
			MaximumParallelInstances =>  0,
			Data                     => 
			{
				Object   => 'Kernel::System::CustomMessage',
				Function => 'SendMessageMSTeams',
				Params   => 
						{
							MSTeamWebhookURL	=>	$MSTeamWebhookURL,
							MessageSubject	=>	$MessageSubject,
							MessageText	=>	$MessageText1,
							TicketNumber	=>	$Ticket{TicketNumber},
							Created	=> $DateTimeString,
							Queue	=> $Ticket{Queue},
							Service	=>	$Ticket{Service},
							Priority=>	$Ticket{Priority},
							TicketURL	=>	$TicketURL,
							TicketID      => $TicketID, #sent for log purpose

						},
			},
		);	
						
	}

}

1;

