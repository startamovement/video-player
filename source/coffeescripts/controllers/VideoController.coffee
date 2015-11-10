require('controllers/Events')

@ib ?= {}

class ib.VideoController
  constructor: (@context) ->
    @win = $ window
    @urlId = @context.data 'url'

    template = require 'video_template.html'
    html = template
      urlId: @urlId
    @context.append html

    @playerContainer = @context.find '.player-container'
    @thumbnail = @playerContainer.find 'img'
    @playerEl = @playerContainer.find '.player'
    @playButton = @playerContainer.find 'figure'
    @progressContainer = @playerContainer.find '.progress-container'
    @progressBar = @progressContainer.find '.bar'

  init: ->
    @player = new YT.Player @playerEl.get(0),
      videoId: @urlId
      playerVars:
        'autohide': 1
        'controls': 0
        'iv_load_policy': 3
        'showinfo': 0
        'rel': 0
      events:
        'onReady': @onReady
        'onStateChange': @onPlayerStateChange

  onReady: =>
    @context.fadeTo 400, 1

    video = @context.find 'iframe'
    @ratio = video.height()/video.width()
    @totalTime = @player.getDuration()

    @resize()
    @bindEvents()

  bindEvents: =>
    @win.on ib.Events.PAUSE_VIDEOS, =>
      @player.pauseVideo()
    @win.on 'resize', @resize
    @playButton.on 'click', @playButtonHandler
    @progressContainer.on 'click', @seekTo
    @progressContainer.on 'mousedown', @seekOn

  resize: =>
    newWidth = @context.width()
    newHeight = newWidth*@ratio

    @playerContainer.height newHeight
    @context.height newHeight
    @player.setSize newWidth, newHeight

  onPlayerStateChange: (event) =>
    clearInterval @progress

    if event.data is YT.PlayerState.PLAYING
      @context.removeClass 'inactive'
      @progressBarOn()
      @player.mute()

    else if event.data is YT.PlayerState.PAUSED
      @context.addClass 'inactive'

    else if event.data is YT.PlayerState.ENDED
      @context.addClass 'inactive'
      @thumbnail.show()

  playButtonHandler: =>
    @thumbnail.hide()
    if @context.hasClass 'inactive'
      @win.trigger ib.Events.PAUSE_VIDEOS
      @player.playVideo()
    else
      @player.pauseVideo()

  progressBarOn: =>
    @progress = setInterval =>
      currentTime = @player.getCurrentTime()
      diff = currentTime/@totalTime

      @updateProgressBar diff
    , 250

  updateProgressBar: (percentage) =>
    @progressBar.width percentage*100+'%'

  seekOn: =>
    @win.on 'mouseup', @seekOff
    @win.on 'mousemove', @seekTo

  seekOff: =>
    @win.off 'mouseup', @seekOff
    @win.off 'mousemove', @seekTo

  seekTo: (e) =>
    x = e.clientX
    offset = @progressContainer.offset().left
    width = @progressContainer.width()

    diff = x - offset
    percentage = diff/width
    time = percentage*@totalTime

    @updateProgressBar percentage
    @player.seekTo time