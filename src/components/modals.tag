modals

    // TODO: Добавить анимацию для modal-backdrop
    .modal-backdrop(class='fade { "in": backdrop, "hidden": !backdrop }')

    script(type='text/babel').
        var self = this,
            modals = [],
            count = 0

        self.backdrop = false
        //self.backdropHidden = true

        self.create = function (name, opts) {
            var elem = document.createElement('div')
            self.root.appendChild(elem)

            var modal = riot.mount(elem, name, opts)[0]

            if (modal) {
                if (modals.length > 0) {
                    modals[modals.length - 1].modalHide()
                } else {
                    self.backdrop = true
                    self.update()
                }

                modal.modalUID = ++count
                modals.push(modal)

                modal.on('shown', function () {
                    document.body.classList.add('modal-open')
                })

                modal.on('hidden', function () {
                    if (this.modalUID == count && modals.length > 0) {
                        var m = modals.pop()
                        m.unmount()
                        --count
                        if (modals.length > 0) {
                            modals[modals.length - 1].modalShow()
                        } else {
                            document.body.classList.remove('modal-open')
                            self.backdrop = false
                            self.update()
                        }
                    }
                })

                modal.modalShow()
                return modal
            }
        }

bs-modal
    .modal(onclick='{ !cannotBeClosed ? close : "close" }', tabindex='-1',
    style='{ "display: block;": animationEnd, "display: none;": !animationEnd }')
        .modal-dialog(class='{ modalVisible ? animation.show : animation.hide } { parent.opts.size }')
            .modal-content
                .modal-header(class='{ parent.opts.type }')
                    button.close(onclick='{ !cannotBeClosed ? modalHide : "modalHide" }', type='button')
                        span &times;
                    #{'yield'}(from='title')
                .modal-body
                    #{'yield'}(from='body')
                .modal-footer
                    #{'yield'}(from='footer')

    style(scoped).
        .modal-dialog {
            -webkit-animation-duration: .4s;
            animation-duration: .4s;
        }

        .modal-default, .modal-primary, .modal-success, .modal-info, .modal-warning, .modal-danger {
            border-radius: 4px 4px 0 0;
        }

        .modal-default {
            background-color: #FFFFFF;
            color: #333;
        }

        .modal-primary {
            background-color: #337AB5;
            color: #fff;
        }

        .modal-success {
            background-color: #5CB85C;
            color: #fff;
        }

        .modal-info {
            background-color: #5BC0DE;
            color: #fff;
        }

        .modal-warning {
            background-color: #F0AD4E;
            color: #fff;
        }

        .modal-danger {
            background-color: #D9534F;
            color: #fff;
        }


    script(type='text/babel').
        var self = this

        self.cannotBeClosed = false
        self.modalVisible = false
        self.animationEnd = false
        self.items = []

        self.animation = {
            show: 'animated fadeInDown',
            hide: 'animated fadeOutUp'
        }

        if (self.parent.opts.animation) {
            self.animation = {
                show: self.parent.opts.animation.show || 'animated fadeInDown',
                hide: self.parent.opts.animation.hide || 'animated fadeOutUp'
            }
        }

        //self.stopPropagation = function (e) {
        //    e.stopPropagation()
        //}

        self.close = function (e) {
            if (e.target == self.root.children[0])
                self.modalHide()
            return true
        }

        self.modalHide = function () {
            self.modalVisible = false
            self.parent.trigger('hide')
            var end = function () {
                self.animationEnd = false
                self.parent.trigger('hidden');
                this.removeEventListener('animationend', end)
                this.removeEventListener('webkitAnimationEnd', end)
                this.removeEventListener('oAnimationEnd', end)
            }
            self.root.addEventListener('animationend', end)
            self.root.addEventListener('webkitAnimationEnd', end)
            self.root.addEventListener('oAnimationEnd', end)
            //self.root.addEventListener('transitionend', end)
            self.update()
        }

        self.modalShow = function () {
            self.parent.trigger('show')
            self.modalVisible = true
            self.animationEnd = true
            var end = function () {
                self.parent.trigger('shown');
                this.removeEventListener('animationend', end)
                this.removeEventListener('webkitAnimationEnd', end)
                this.removeEventListener('oAnimationEnd', end)
            };
            self.root.addEventListener('animationend', end)
            self.root.addEventListener('webkitAnimationEnd', end)
            self.root.addEventListener('oAnimationEnd', end)
            //self.root.addEventListener('transitionend', end)
            self.update()
        }

        if (self.parent) {
            self.parent.modalVisible = self.modalVisible
            self.parent.modalHide = self.modalHide
            self.parent.modalShow = self.modalShow
        }

bs-alert
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title.text-center { parent.opts.title }
        #{'yield'}(to="body")
            .text-center { parent.opts.text }
        #{'yield'}(to='footer')
            .text-center
                button(each='{ parent.opts.buttons }', onclick='{ parent.parent.click }', type='button', class='btn { style }') { title }
                
    script(type='text/babel').
        var self = this

        if (!opts.animation) {
            opts.animation = {
                show: 'animated zoomIn',
                hide: 'animated zoomOut'
            }
        }

        self.callback = opts.callback || function (action) { self.modalHide() }
        
        self.click = function (e) {
            self.callback(e.item.action)
        }

bs-prompt
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title { parent.opts.title }
        #{'yield'}(to="body")
            .form-group
                label.control-label { parent.opts.label }
                input.form-control(type='{ parent.opts.inputType || "text" }', name='{ parent.opts.inputName || "name" }',
                min='{ parent.opts.min }', max='{ parent.opts.max }', step='{ parent.opts.step }')
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Сохранить