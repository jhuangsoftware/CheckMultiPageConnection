<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="expires" content="-1"/>
	<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
	<meta name="copyright" content="2013, Web Solutions"/>
	<meta http-equiv="X-UA-Compatible" content="IE=edge" >
	<title>Page Connections</title>
	<link rel="stylesheet" href="css/bootstrap.min.css" />
	<style type="text/css">
		body
		{
			padding: 10px;
		}
	</style>
	<script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
	<script type="text/javascript" src="js/bootstrap.min.js"></script>
	<script type="text/javascript" src="rqlconnector/Rqlconnector.js"></script>
	<script type="text/javascript">
		function GotoTreeSegment(sGuid, sType)
		{
			top.opener.parent.top.opener.parent.frames.ioTreeData.location = "../../ioRDLevel1.asp?Action=GotoTreeSegment&Guid=" + sGuid + "&Type=" + sType + "&CalledFromRedDot=0";
		}
	</script>
	<script type="text/javascript">
		var LoginGuid = '<%= session("loginguid") %>';
		var SessionKey = '<%= session("sessionkey") %>';
		var RqlConnectorObj = new RqlConnector(LoginGuid, SessionKey);
		var _PageGuid = GetUrlVars()['pageguid'];
	
		$(document).ready(function() {
			DisplayPageConnections(_PageGuid);
			
			$("#connections").on("click", ".display-in-tree", function(event){
				GotoTreeSegment($(this).attr('data-guid'), 'link');
			});
			
			$("#connections").on("click", ".reference-page", function(event){
				ReferenceLinkToPage($(this).attr('data-guid'), _PageGuid);
			});
		});
		
		function GetUrlVars()
		{
			var vars = [], hash;
			var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
			for(var i = 0; i < hashes.length; i++)
			{
				hash = hashes[i].split('=');
				vars.push(hash[0]);
				vars[hash[0]] = hash[1];
			}
	
			return vars;
		}
		
		function DisplayPageConnections(PageGuid)
		{
			var strRQLXML = '<PAGE guid="' + PageGuid + '"><LINKSFROM action="load"/></PAGE>';
			
			RqlConnectorObj.SendRql(strRQLXML, false, function(data){
				$(data).find('LINK').each(function(){
					var ButtonHTML = '';
					ButtonHTML = '<button class="btn display-in-tree" data-guid="' + $(this).attr('guid') + '" title="Display in Tree"><i class="icon-share-alt"></i></button>';
					
					var PageHeadline = $(this).attr('pageheadline');
					
					var ElementNameAndConnectionType = '<span>' + $(this).attr('value') + '</span>&nbsp;';
					
					if($(this).attr('ismainlink') != '0')
					{
						// is mainlink
						ElementNameAndConnectionType += '<i class="icon-home" title="Mainlink"></i>';
					}
					else
					{
						var elttype = parseInt($(this).attr("elttype"));
						if((elttype == 26) || (elttype == 27))
						{
							ButtonHTML += '<button class="btn btn-info reference-page" data-guid="' + $(this).attr('guid') + '" title="Reference Page"><i class="icon-arrow-right"></i></button>';
						}
					}
					
					if($(this).attr('connectedbykeyword') == '1')
					{
						// is connected via keyword
						ElementNameAndConnectionType += '<i class="icon-info-sign" title="Connected via Keyword"></i>';
					}

					AddPageConnection($(this).attr('pageheadline'), ElementNameAndConnectionType, ButtonHTML);
				});
				
			});
		}
		
		function AddPageConnection(ParentPageHeadline, ConnectedElementHtml, ActionsHtml)
		{
			var ConnectionHTML = '';
			ConnectionHTML += '<tr>';
			ConnectionHTML += '<td>' + ParentPageHeadline + '</td>'
			ConnectionHTML += '<td>' + ConnectedElementHtml + '</td>';
			ConnectionHTML += '<td>' + ActionsHtml + '</td>';
			ConnectionHTML += '</tr>';
			
			$('#connections tbody').append(ConnectionHTML);
		}
		
		function ReferenceLinkToPage(LinkGuid, PageGuid)
		{
			var strRQLXML = '<CLIPBOARD action="ReferenceToPage" guid="' + LinkGuid + '" type="link"><ENTRY guid="' + PageGuid + '" type="page" /></CLIPBOARD>';
			
			RqlConnectorObj.SendRql(strRQLXML, false, function(data){			
				RefreshPage();
			});
		}
		
		function RefreshPage()
		{
			location.reload();
		}
	</script>
</head>
<body>
    <table class="table table-hover" id="connections">
		<tbody>
			<tr class="info">
				<td><strong>Parent Page</strong></td>
				<td><strong>Connected to Element</strong></td>
				<td><strong>Actions</strong></td>
			</tr>
		</tbody>
    </table>
</body>
</html>