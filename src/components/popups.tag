popups
    .popups.popups-top-left(name='tl', style='margin: { opts.margin != "" ? opts.margin : "0" }')
    .popups.popups-top-right(name='tr', style='margin: { opts.margin != "" ? opts.margin : "0" }')
    .popups.popups-bottom-right(name='br', style='margin: { opts.margin != "" ? opts.margin : "0" }')
    .popups.popups-bottom-left(name='bl', style='margin: { opts.margin != "" ? opts.margin : "0" }')

    style(scoped).
        .popups {
            position: fixed;
            width: 250px;
            z-index: 9999;
            -webkit-hyphens: auto;
            -moz-hyphens: auto;
            -ms-hyphens: auto;
            hyphens: auto;
            word-wrap: break-word;
        }

        .popups-top-left {
            top: 0;
            left: 0;
        }

        .popups-top-right {
            top: 0;
            right: 0;
        }

        .popups-bottom-left {
            bottom: 0;
            left: 0;
        }

        .popups-bottom-right {
            bottom: 0;
            right: 0;
        }

    script(type='text/babel').
        var self = this;

        self.create = function (params) {
            if (!params) return;

            var popup = document.createElement('bs-popup');
            var position = params.position || opts.position || undefined,
                animation = params.animation || opts.animation || undefined,
                timeout = 5000;

            if (opts.timeout !== undefined && typeof parseInt(opts.timeout) === 'number') {
                timeout = parseInt(opts.timeout);
            }
            if (params.timeout !== undefined && typeof parseInt(params.timeout) === 'number') {
                timeout = parseInt(params.timeout);
            }

            if (position && typeof position === 'string') {
                if (position === 'top-left')
                    self.tl.insertBefore(popup, null);
                if (position === 'top-right')
                    self.tr.insertBefore(popup, null);
                if (position === 'bottom-right')
                    self.br.insertBefore(popup, self.br.children[0]);
                if (position === 'bottom-left') {
                    self.bl.insertBefore(popup, self.bl.children[0]);
                }
            } else {
                self.tr.insertBefore(popup, null);
            }

            popup = riot.mount(popup, 'bs-popup', {
                title:      params.title,
                text:       params.text,
                style:      params.style || 'popup-primary',
                animation:  animation,
                position:   position || 'top-right'
            })[0];

            if (timeout != 0) {
                popup.timer = setTimeout(function () {
                    popup.close();
                }, timeout + 300);
            }
        }

bs-popup
    div(onclick='{ close }', class='popup { opts.style } { css }')
        .h4(if='{ opts.title }') { opts.title }
        p(if='{ opts.text }') { opts.text }

    style(scoped).
        .popup {
            background-color: rgba(60, 60, 60, 0.95);
            padding: 6px;
            color: #fff;
            margin: 5px;
            z-index: 9999;
            border-radius: 5px;
            -webkit-box-shadow: 0 3px 9px rgba(0, 0, 0, .5);
            box-shadow: 0 3px 9px rgba(0, 0, 0, .5);
            -webkit-animation-duration: 0.3s;
            animation-duration: 0.3s;
        }

        .popup-default {
            background-color: rgba(255, 255, 255, 0.95);
            color: #333;
            border-color: #ccc;
        }

        .popup-primary {
            background-color: rgba(51, 122, 183, 0.95);
            color: #fff;
            border-color: #2e6da4;
        }

        .popup-success {
            background-color: rgba(92, 184, 92, 0.95);
            color: #fff;
            border-color: #4cae4c;
        }

        .popup-info {
            background-color: rgba(91, 192, 222, 0.95);
            color: #fff;
            border-color: #46b8da;
        }

        .popup-warning {
            background-color: rgba(240, 173, 78, 0.95);
            color: #fff;
            border-color: #eea236;
        }

        .popup-danger {
            background-color: rgba(217, 83, 79, 0.95);
            color: #fff;
            border-color: #d43f3a;
        }

        .popup p {
            margin: 0px;
        }

        .popup .h4, .popup .h5, .popup .h6, .popup h4, .popup h5, .popup h6 {
            margin-top: 0;
        }

    script.
        var self = this,
            animations = ['bounce', 'slide', 'fade', 'zoom'],
            isAnimation = animations.indexOf(opts.animation) > -1,
            direction = opts.position.indexOf('right') > -1 ? 'Right' : 'Left',
            css = {
                show: (isAnimation ? opts.animation + 'In' + direction + ' animated': ''),
                hide: (isAnimation ? opts.animation + 'Out' + direction + ' animated': '')
            }

        self.css = css.show

        self.close = function () {
            if (self.timer)
                clearTimeout(self.timer)

            if (isAnimation) {
                self.css = css.hide
                self.update()
                setTimeout(function () {
                    self.unmount()
                }, 300)
            } else {
                self.unmount()
            }
        }