client = new Faye.Client("http://127.0.0.1:1080/kyatchi")
allMessages = []
messageCount = 0

currentEmail = client.subscribe '/current_email', (message) ->
  allMessages.push(message)
  messageCount += 1
  
  $('#messages tbody').append \
    $('<tr />').attr('data-message-id', messageCount)
      .append($('<td/>').text(message.from))
      .append($('<td/>').text(message.to))
      .append($('<td/>').text(message.subject))
      .append($('<td/>').text(message.created_at))

$('#messages tr').live 'click', (e) => loadMessage $(e.currentTarget).attr('data-message-id')
  
$('#message .views .tab').live 'click', (e) =>
  loadMessageBody $('#messages tr.selected').attr('data-message-id'), $(e.currentTarget).attr 'data-message-format'
  
$('nav.app .clear a').live 'click', (e) =>
  if confirm "You will lose all your received messages.\n\nAre you sure you want to clear all messages?"
    allMessages = []
    messageCount = 0
    $('#messages tbody').empty()
    $('#message .metadata dd').empty()
    $('#message div.body').empty()

loadMessage = (id) ->
  selectedId = id
  selectedIndex = selectedId - 1
  $('#messages tbody tr:not([data-message-id="'+selectedId+'"])').removeClass 'selected'
  $('#messages tbody tr[data-message-id="'+selectedId+'"]').addClass 'selected'
  
  $('#message .metadata dd.created_at').text allMessages[selectedIndex].created_at
  $('#message .metadata dd.from').text allMessages[selectedIndex].from
  $('#message .metadata dd.to').text allMessages[selectedIndex].to
  $('#message .metadata dd.subject').text allMessages[selectedIndex].subject
  
  if $("#message .views .tab.selected:not(:visible)").length
    $("#message .views .tab.selected").removeClass "selected"
    $("#message .views .tab:visible:first").addClass "selected"
  
  $('#message .download a').attr 'href', "download/#{id}?email=#{allMessages[selectedIndex].content.source}"
  loadMessageBody()

loadMessageBody = (id,format) ->
    id ||= $('#messages tr.selected').attr 'data-message-id'
    format ||= $('#message .views .tab.format.selected').attr 'data-message-format'
    format ||= 'html'
    $("#message .views .tab[data-message-format=#{format}]:not(.selected)").addClass 'selected'
    $("#message .views .tab:not([data-message-format=#{format}]).selected").removeClass 'selected'
    
    selectedIndex = id - 1
    
    if id?
      content = $(allMessages[selectedIndex].content[format])
      content = allMessages[selectedIndex].content[format] unless format is 'html'
      $('#message div.body').html content