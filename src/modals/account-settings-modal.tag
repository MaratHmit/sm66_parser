account-settings-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Управление аккаунтами
        #{'yield'}(to="body")
            catalog(object='Account', add='{ parent.add }', remove='{ parent.remove }', cookie='{ parent.app.mainCookie }',
            disable-pagination='true', disable-limit='true', reload='true', before-success='{ parent.beforeSuccess }',
            cols='{ parent.cols }', disable-col-select='true')
                #{'yield'}(to='body')
                    datatable-cell(name='alias') { row.alias }
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть

    script(type='text/babel').
        var self = this

        self.cols = [
            {name: 'alias', value: 'Аккаунт'}
        ]

        self.app = app

        self.beforeSuccess = function (response) {
            let mainUser = JSON.parse(localStorage.getItem('shop24_main_user'))
            let config = JSON.parse(localStorage.getItem('shop24'))

            response.items = response.items.filter(item => {
                return (item.login !== config.login) && (item.login !== mainUser.login) && (item.login !== null)
            })
        }

        self.remove = function (e, items, tag) {
            var self = this,
            params = {ids: items}

            modals.create('bs-alert', {
                type: 'modal-danger',
                title: 'Предупреждение',
                text: items.length > 1
                    ? 'Вы точно хотите удалить эти записи?'
                    : 'Вы точно хотите удалить эту запись?',
                size: 'modal-sm',
                buttons: [
                    {action: 'yes', title: 'Удалить', style: 'btn-danger'},
                    {action: 'no', title: 'Отмена', style: 'btn-default'},
                ],
                callback: function (action) {
                    if (action === 'yes') {
                        API.request({
                            object: 'Account',
                            method: 'Delete',
                            cookie: app.mainCookie,
                            data: params,
                            success(response) {
                                popups.create({title: 'Успешно удалено!', style: 'popup-success'})
                                observable.trigger('accounts-change')
                                tag.reload()
                            }
                        })
                    }
                    this.modalHide()
                }
            })
        }

        self.add = () => {
            modals.create('account-add-modal', {
                type: 'modal-primary',
                size: 'modal-sm',
                success() {
                    self.tags['bs-modal'].tags.catalog.reload()
                }
            })
        }
