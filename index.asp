<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="expires" content="-1"/>
	<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
	<meta name="copyright" content="2013, Web Solutions"/>
	<meta http-equiv="X-UA-Compatible" content="IE=edge" >
	<title>Check Page Appearance</title>
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
			top.opener.parent.frames.ioTreeData.location="../../ioRDLevel1.asp?Action=GotoTreeSegment&Guid=" + sGuid + "&Type=" + sType + "&CalledFromRedDot=0";
		}
	</script>
	<script type="text/javascript">
		var LoginGuid = '<%= session("loginguid") %>';
		var SessionKey = '<%= session("sessionkey") %>';
		var TreeGuid = '<%= session("TreeGuid") %>';
		var RqlConnectorObj = new RqlConnector(LoginGuid, SessionKey);
	
		var GlobalThreadIdCounter = 0;
	
		$(document).ready(function() {
			$('#search-option-dialog').modal('show');
			
			$('#searchresults').hide();
		});
		
		function Search()
		{
			$('#search-option-dialog').modal('hide');

			$('#searchresults').show();
			ListAllPageInstances(TreeGuid, $('#maxnumberofpage').val());
			
			$("#searchresults").on("click", ".display-in-tree", function(event){
				GotoTreeSegment($(this).attr('data-guid'), 'page');
			});
			
			$("#searchresults").on("click", ".page-connections", function(event){
				ConnectionsUsagePopup($(this).attr('data-guid'));
				$(this).parent().toggleClass('alert-success', true);
				$(this).parent().toggleClass('alert-info', false);
			});
		}
		
		function ListAllPageInstances(ContentClassGuid, MaxNumberOfPages)
		{
			var ThreadId = getThread();
			displayToThread(ThreadId, 'warning', 'Initializing search.');
		
			var strRQLXML = '<PAGE action="xsearch" pagesize="-1" maxhits="' + MaxNumberOfPages + '"><SEARCHITEMS><SEARCHITEM key="contentclassguid" value="' + ContentClassGuid + '" operator="eq"></SEARCHITEM></SEARCHITEMS></PAGE>';
			
			RqlConnectorObj.SendRql(strRQLXML, false, function(data){
				var PageGuidsToCheck1 = new Array();
				var PageGuidsToCheck2 = new Array();
				var PageGuidsToCheck3 = new Array();
				var PageGuidsToCheck4 = new Array();
				
				$('.SearchResultsArea').empty();
				$(data).find('PAGE').each( function(index) {
					var Page = new Object();
					Page.guid = $(this).attr('guid');
					Page.id = $(this).attr('id');
					Page.headline = $(this).attr('headline');
					
					switch(index % 4)
					{
						case 0:
							PageGuidsToCheck1.push(Page);
							break;
						case 1:
							PageGuidsToCheck2.push(Page);
							break;
						case 2:
							PageGuidsToCheck3.push(Page);
							break;
						case 3:
							PageGuidsToCheck4.push(Page);
							break;
						default:
							PageGuidsToCheck1.push(Page);
					}
				});
				
				displayToThread(ThreadId, 'ok', 'Initialization completed.', true);
				killThread(ThreadId);
				
				var ThreadId1 = getThread();
				var ThreadId2 = getThread();
				var ThreadId3 = getThread();
				var ThreadId4 = getThread();
				
				CheckPage(PageGuidsToCheck1, ThreadId1);
				CheckPage(PageGuidsToCheck2, ThreadId2);
				CheckPage(PageGuidsToCheck3, ThreadId3);
				CheckPage(PageGuidsToCheck4, ThreadId4);
			});
		}
		
		function CheckPage(PagesGuidsArray, ThreadId)
		{
			var Page = PagesGuidsArray.shift();
			
			displayToThread(ThreadId, 'warning', 'Checking...' + PagesGuidsArray.length + ' pages remaining.', true);
			
			if(Page != null)
			{			
				var strRQLXML = '<PAGE guid="' + Page.guid + '"><LINKSFROM action="load"/></PAGE>';
				
				RqlConnectorObj.SendRql(strRQLXML, false, function(data){
					var ConnectionType = 'LINK[ismainlink="0"]';
					
					if($('#connectedbykeyword').is(':checked'))
					{
					}
					else
					{
						ConnectionType += '[connectedbykeyword="0"]';
					}

					if($(data).find(ConnectionType).length)
					{
						var SearchResult = $('#templates .alert-info').clone();
						$(SearchResult).find('.display-in-tree').attr('data-guid', Page.guid);
						$(SearchResult).find('.page-connections').attr('data-guid', Page.guid);
						$(SearchResult).find('.page-connections').text('(' + Page.id + ') ' + Page.headline);
						$('#searchresults').append(SearchResult);
					}
					
					CheckPage(PagesGuidsArray, ThreadId);
				});
			}
			else
			{
				displayToThread(ThreadId, 'ok', 'Checking Completed', true);
				killThread(ThreadId);
			}
		}
		
		function getThread()
		{
			var ThreadId = 't' + GlobalThreadIdCounter;
			GlobalThreadIdCounter++;
			var ThreadClone = $('#templates .threadcontent').clone();
			$(ThreadClone).attr('id', ThreadId);
			$('#status-area').append(ThreadClone);
			$(ThreadClone).show();
			return ThreadId;
		}
		
		function displayToThread(threadId, status, text, overwrite)
		{
			var threadDom = $('#' + threadId);
			switch(status){
				case 'ok':
					$(threadDom).toggleClass('alert-success', true);
					$(threadDom).toggleClass('alert-error', false);
					break
				case 'warning':
					$(threadDom).toggleClass('alert-success', false);
					$(threadDom).toggleClass('alert-error', false);
					break
				case 'error':
					$(threadDom).toggleClass('alert-success', false);
					$(threadDom).toggleClass('alert-error', true);
					break
			}
			
			if(overwrite)
			{
				$(threadDom).empty();
			}
				
			$(threadDom).append('<div>' + text + '</div>');
		}
		
		function killThread(threadId)
		{
			var threadDom = $('#' + threadId);
			$(threadDom).remove();
		}
		
		function getRunningThreadCount()
		{
			return $('#status-area .threadcontent').length;
		}
		
		function ConnectionsUsagePopup(PageGuid)
		{
			var PopUpUrl = 'connections.asp?pageguid=' + PageGuid;
			window.open(PopUpUrl, 'PageConnections', 'width=800,height=600,scrollbars=yes,resizable=yes'); 
		}
	</script>
</head>
<body>
	<div id="search-option-dialog" class="modal hide fade" data-backdrop="static" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<div class="modal-header">
			<h3 id="myModalLabel">Check Page Appearance</h3>
		</div>
		<div class="modal-body">
			<div class="form-horizontal">
				<div class="control-group">
					<label class="control-label" for="search-field">Max Search</label>
					<div class="controls">
						<input type="text" maxlength="4" value="200" id="maxnumberofpage"/>
						<label class="checkbox" for="connectedbykeyword"><input type="checkbox" id="connectedbykeyword"/> Include connection via category and keyword</label>
					</div>
				</div>
			</div>
		</div>
		<div class="modal-footer">
			<button href="#" class="btn btn-success" onclick="Search();">Search</button>
		</div>
	</div>
	<div id="templates" style="display: none;">
		<div class="alert threadcontent">
		</div>
		<div class="alert alert-info">
			<button class="btn display-in-tree" title="Display in Tree"><i class="icon-share-alt"></i></button>
			<button class="btn page-connections" title="Display Connections"></button>
		</div>
	</div>
	<div id="status-area">
	</div>
	<div id="searchresults">
	</div>
</body>
</html>