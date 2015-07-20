@ib ?= {}

class ib.VideoController
  constructor: (@context) ->
    @win = $ window
    @playerContainer = @context.find '.player-container'
    @thumbnail = @playerContainer.find 'img'
    @playerEl = @playerContainer.find 'div'
    @playButton = @playerContainer.find 'figure'
    @progressContainer = @playerContainer.find '.progress-container'
    @progressBar = @progressContainer.find '.bar'

  init: ->
    url = @context.data 'url'

    @player = new YT.Player @playerEl.get(0),
      videoId: url
      playerVars:
        'autohide': 1
        'controls': 0
        'iv_load_policy': 3
        'showinfo': 0
        'rel': 0
      events:
        'onReady': @onReady
        'onStateChange': @onPlayerStateChange

  bindEvents: =>
    @win.on ib.Events.PAUSE_VIDEOS, @pause
    @win.on 'resize', @resize
    @playButton.on 'click', @playButtonHandler
    @progressContainer.on 'click', @seekTo
    @progressContainer.on 'mousedown', @seekOn
    @progressContainer.on 'mouseup', @seekOff

  resize: =>
    newWidth = @context.width()
    newHeight = newWidth*@ratio

    @playerContainer.height newHeight
    @context.height newHeight
    @player.setSize width = newWidth, height = newHeight

  onReady: =>
    @totalTime = @player.getDuration()
    video = @context.find 'iframe'
    @ratio = video.height()/video.width()

    @resize()
    @bindEvents()

    @context.addClass 'inactive ready'

  onPlayerStateChange: (event) =>
    clearInterval @progress if @progress

    if event.data == YT.PlayerState.PLAYING
      @context.removeClass 'inactive'
      @progressBarOn()

    else if event.data is YT.PlayerState.PAUSED
      @context.addClass 'inactive'

    else if event.data is YT.PlayerState.ENDED
      @context.addClass 'inactive'
      @thumbnail.removeClass 'hide'

  playButtonHandler: =>
    if @context.hasClass 'inactive'
      @win.trigger ib.Events.PAUSE_VIDEOS
      @player.playVideo()
      if not @thumbnail.hasClass 'hide'
        @thumbnail.addClass 'hide'
    else
      @pause()

  pause: =>
    @player.pauseVideo()

  progressBarOn: =>
    @progress = setInterval =>
      currentTime = @player.getCurrentTime()
      diff = (currentTime/@totalTime)*100

      @updateProgressBar diff
    , 500

  updateProgressBar: (percentage) =>
    @progressBar.width(percentage + '%')

  seekOn: =>
    @progressContainer.on 'mousemove', @seekTo

  seekOff: =>
    @progressContainer.off 'mousemove', @seekTo

  seekTo: (e) =>
    x = e.clientX
    offset = @progressContainer.offset().left
    width = @progressContainer.width()

    diff = x - offset
    percentage = diff/width
    time = percentage * @totalTime

    @updateProgressBar(percentage*100)
    @player.seekTo seconds = time


