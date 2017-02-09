loader
    .dimmer(class='{inverted: opts.inverted}')
        .loader(class='{opts.size} {text: opts.text} { indeterminate: opts.indeterminate }') {opts.text}
    style(scoped).
        :scope {
            background-color: rgba(255, 255, 255, 1);
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            min-height: 100px;
            height: 100%;
            z-index: 40;
        }

        .loader {
            display: none;
            position: absolute;
            top: 50%;
            left: 50%;
            margin: 0;
            text-align: center;
            z-index: 1000;
            -webkit-transform: translateX(-50%) translateY(-50%);
            -ms-transform: translateX(-50%) translateY(-50%);
            transform: translateX(-50%) translateY(-50%)
        }

        .loader:before {
            position: absolute;
            content: '';
            top: 0;
            left: 50%;
            border-radius: 500rem;
            border: .2em solid rgba(0, 0, 0, .1)
        }

        .loader:after {
            position: absolute;
            content: '';
            top: 0;
            left: 50%;
            -webkit-animation: loader .6s linear;
            animation: loader .6s linear;
            -webkit-animation-iteration-count: infinite;
            animation-iteration-count: infinite;
            border-radius: 500rem;
            border-color: #767676 transparent transparent;
            border-style: solid;
            border-width: .2em;
            box-shadow: 0 0 0 1px transparent;
        }

        @-webkit-keyframes loader {
            from {
                -webkit-transform: rotate(0);
                transform: rotate(0);
            }
            to {
                -webkit-transform: rotate(360deg);
                transform: rotate(360deg);
            }
        }

        @keyframes loader {
            from {
                -webkit-transform: rotate(0);
                transform: rotate(0);
            }
            to {
                -webkit-transform: rotate(360deg);
                transform: rotate(360deg);
            }
        }

        .loader:after,
        .loader:before {
            width: 2.2585em;
            height: 2.2585em;
            margin: 0 0 0 -1.12925em;
        }

        .mini.loader:after,
        .mini.loader:before {
            width: 1.2857em;
            height: 1.2857em;
            margin: 0 0 0 -.64285em;
        }

        .small.loader:after,
        .small.loader:before {
            width: 1.7142em;
            height: 1.7142em;
            margin: 0 0 0 -.8571em;
        }

        .large.loader:after,
        .large.loader:before {
            width: 4.5714em;
            height: 4.5714em;
            margin: 0 0 0 -2.2857em;
        }

        .dimmer .loader {
            display: block
        }

        .dimmer .loader {
            color: rgba(0, 0, 0, .87);
        }

        .dimmer .loader:before {
            border-color: rgba(0, 0, 0, .1);

        }

        .dimmer .loader:after {
            border-color: #767676 transparent transparent;
        }

        .inverted.dimmer .loader {
            color: rgba(255, 255, 255, .9);
        }

        .inverted.dimmer .loader:before {
            border-color: rgba(255, 255, 255, .15)
        }

        .inverted.dimmer .loader:after {
            border-color: #fff transparent transparent;
        }

        .text.loader {
            width: auto !important;
            height: auto !important;
            text-align: center;
            font-style: normal
        }

        .indeterminate.loader:after {
            -webkit-animation-direction: reverse;
            animation-direction: reverse;
            -webkit-animation-duration: 1.2s;
            animation-duration: 1.2s
        }

        .loader.active,
        .loader.visible {
            display: block
        }

        .loader.disabled,
        .loader.hidden {
            display: none
        }

        .inverted.dimmer .mini.loader,
        .mini.loader {
            width: 1.2857em;
            height: 1.2857em;
            font-size: .71428571em
        }

        .inverted.dimmer .small.loader,
        .small.loader {
            width: 1.7142em;
            height: 1.7142em;
            font-size: .92857143em
        }

        .inverted.dimmer .loader,
        .loader {
            width: 2.2585em;
            height: 2.2585em;
            font-size: 1em
        }

        .inverted.dimmer .loader.large,
        .loader.large {
            width: 4.5714em;
            height: 4.5714em;
            font-size: 1.14285714em
        }

        .mini.text.loader {
            min-width: 1.2857em;
            padding-top: 1.99998571em
        }

        .small.text.loader {
            min-width: 1.7142em;
            padding-top: 2.42848571em
        }

        .text.loader {
            min-width: 2.2585em;
            padding-top: 2.97278571em
        }

        .large.text.loader {
            min-width: 4.5714em;
            padding-top: 5.28568571em
        }

        .inverted.loader {
            color: rgba(255, 255, 255, .9)
        }

        .inverted.loader:before {
            border-color: rgba(255, 255, 255, .15)
        }

        .inverted.loader:after {
            border-top-color: #fff
        }

        .inline.loader {
            position: relative;
            vertical-align: middle;
            margin: 0;
            left: 0;
            top: 0;
            -webkit-transform: none;
            -ms-transform: none;
            transform: none
        }

        .inline.loader.active,
        .inline.loader.visible {
            display: inline-block
        }

        .centered.inline.loader.active,
        .centered.inline.loader.visible {
            display: block;
            margin-left: auto;
            margin-right: auto
        }

        .dimmer {
            display: block;
            position: absolute;
            top: 0 !important;
            left: 0 !important;
            width: 100%;
            height: 100%;
            text-align: center;
            vertical-align: middle;
            background-color: rgba(255, 255, 255, .85);
            opacity: 1;
            line-height: 1;
            -webkit-animation-fill-mode: both;
            animation-fill-mode: both;
            -webkit-animation-duration: .5s;
            animation-duration: .5s;
            -webkit-transition: background-color .5s linear;
            transition: background-color .5s linear;
            -webkit-user-select: none;
            -moz-user-select: none;
            -ms-user-select: none;
            user-select: none;
            will-change: opacity;
            z-index: 1000;
        }

        .inverted.dimmer {
            background-color: rgba(0, 0, 0, .85);
        }