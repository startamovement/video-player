// Generated by CoffeeScript 1.9.3
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  if (this.ib == null) {
    this.ib = {};
  }

  ib.VideoController = (function() {
    function VideoController(context) {
      this.context = context;
      this.seekTo = bind(this.seekTo, this);
      this.seekOff = bind(this.seekOff, this);
      this.seekOn = bind(this.seekOn, this);
      this.updateProgressBar = bind(this.updateProgressBar, this);
      this.progressBarOn = bind(this.progressBarOn, this);
      this.pause = bind(this.pause, this);
      this.playButtonHandler = bind(this.playButtonHandler, this);
      this.onPlayerStateChange = bind(this.onPlayerStateChange, this);
      this.onReady = bind(this.onReady, this);
      this.resize = bind(this.resize, this);
      this.bindEvents = bind(this.bindEvents, this);
      this.win = $(window);
      this.playerContainer = this.context.find('.player-container');
      this.thumbnail = this.playerContainer.find('img');
      this.playerEl = this.playerContainer.find('div');
      this.playButton = this.playerContainer.find('figure');
      this.progressContainer = this.playerContainer.find('.progress-container');
      this.progressBar = this.progressContainer.find('.bar');
    }

    VideoController.prototype.init = function() {
      var url;
      url = this.context.data('url');
      return this.player = new YT.Player(this.playerEl.get(0), {
        videoId: url,
        playerVars: {
          'autohide': 1,
          'controls': 0,
          'iv_load_policy': 3,
          'showinfo': 0
        },
        events: {
          'onReady': this.onReady,
          'onStateChange': this.onPlayerStateChange
        }
      });
    };

    VideoController.prototype.bindEvents = function() {
      this.win.on(ib.Events.PAUSE_VIDEOS, this.pause);
      this.win.on('resize', this.resize);
      this.playButton.on('click', this.playButtonHandler);
      this.progressContainer.on('click', this.seekTo);
      this.progressContainer.on('mousedown', this.seekOn);
      return this.progressContainer.on('mouseup', this.seekOff);
    };

    VideoController.prototype.resize = function() {
      var height, newHeight, newWidth, width;
      newWidth = this.context.width();
      newHeight = newWidth * this.ratio;
      this.playerContainer.height(newHeight);
      this.context.height(newHeight);
      return this.player.setSize(width = newWidth, height = newHeight);
    };

    VideoController.prototype.onReady = function() {
      var video;
      this.totalTime = this.player.getDuration();
      video = this.context.find('iframe');
      this.ratio = video.height() / video.width();
      this.resize();
      this.bindEvents();
      return this.context.addClass('inactive ready');
    };

    VideoController.prototype.onPlayerStateChange = function(event) {
      if (this.progress) {
        clearInterval(this.progress);
      }
      if (event.data === YT.PlayerState.PLAYING) {
        this.context.removeClass('inactive');
        return this.progressBarOn();
      } else if (event.data === YT.PlayerState.PAUSED || event.data === YT.PlayerState.ENDED) {
        return this.context.addClass('inactive');
      }
    };

    VideoController.prototype.playButtonHandler = function() {
      if (this.context.hasClass('inactive')) {
        this.win.trigger(ib.Events.PAUSE_VIDEOS);
        this.player.playVideo();
        if (!this.thumbnail.hasClass('hide')) {
          return this.thumbnail.addClass('hide');
        }
      } else {
        return this.pause();
      }
    };

    VideoController.prototype.pause = function() {
      return this.player.pauseVideo();
    };

    VideoController.prototype.progressBarOn = function() {
      return this.progress = setInterval((function(_this) {
        return function() {
          var currentTime, diff;
          currentTime = _this.player.getCurrentTime();
          diff = (currentTime / _this.totalTime) * 100;
          return _this.updateProgressBar(diff);
        };
      })(this), 500);
    };

    VideoController.prototype.updateProgressBar = function(percentage) {
      return this.progressBar.width(percentage + '%');
    };

    VideoController.prototype.seekOn = function() {
      return this.progressContainer.on('mousemove', this.seekTo);
    };

    VideoController.prototype.seekOff = function() {
      return this.progressContainer.off('mousemove', this.seekTo);
    };

    VideoController.prototype.seekTo = function(e) {
      var diff, offset, percentage, seconds, time, width, x;
      x = e.clientX;
      offset = this.progressContainer.offset().left;
      width = this.progressContainer.width();
      diff = x - offset;
      percentage = diff / width;
      time = percentage * this.totalTime;
      this.updateProgressBar(percentage * 100);
      return this.player.seekTo(seconds = time);
    };

    return VideoController;

  })();

}).call(this);