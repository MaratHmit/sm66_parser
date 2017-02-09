| import debounce from 'lodash/debounce'
| import 'components/treeview.tag'

catalog-tree
    .row
        .col-md-8.col-sm-6.col-xs-12
            .form-inline.m-b-2
                button.btn.btn-primary(if='{ opts.add }', onclick='{ opts.add }', type='button')
                    i.fa.fa-plus
                    |  Добавить
                button.btn.btn-success(if='{ opts.reload }', onclick='{ reload }', title='Обновить', type='button')
                    i.fa.fa-refresh
                button.btn.btn-danger(if='{ opts.remove && selectedCount }', onclick='{ remove }', title='Удалить', type='button')
                    i.fa.fa-trash { (selectedCount > 1) ? "&nbsp;" : "" }
                    span.badge(if='{ selectedCount > 1 }') { selectedCount }
                #{'yield'}(from='head')
        .col-md-4.col-sm-6.col-xs-12
            form.form-inline.text-right.m-b-2
                .form-group
                    .input-group(if='{ opts.search }')
                        input.form-control(name='search', type='text', placeholder='Поиск', onkeyup='{ find }')
                        span.input-group-btn
                            button.btn.btn-default(onclick='{ find }', type='submit')
                                i.fa.fa-search

    .row
        .col-md-12
            treeview(nodes='{ nodes }', handlers='{ opts.handlers }', label-field='{ opts.labelField }',
            children-field='{ opts.childrenField }', loader='{ loader }', descendants='{ opts.descendants }')
                #{'yield'}(to='before')
                    #{'yield'}(from='before')
                #{'yield'}(to='after')
                    #{'yield'}(from='after')

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.nodes = []
        self.selectedCount = 0
        self.handlers = opts.handlers


        self.reload = () => {
            self.trigger('reload')
            self.loader = true
            self.update()

            var params = {}
            params.isTree = true

            if (opts.search && self.search) {
                params.searchText = self.search.value
            }

            API.request({
                object: opts.object,
                method: 'Fetch',
                data: params,
                success(response) {
                    self.nodes = response.items
                },
                complete() {
                    self.loader = false
                    self.update()
                }
            })
        }

        self.remove = e => {
            var _this = this

            let items = self.tags.treeview.getSelectedNodes()
            let itemsToRemove = items.map(i => i.id)

            if (opts.remove)
                opts.remove.bind(this, e, itemsToRemove, self)()
        }

        self.find = debounce(e => {
            self.reload()
        }, 400)

        self.on('mount', () => {
            self.reload()
        })

        self.on('update', () => {
            self.handlers = opts.handlers
        })

        self.one('updated', () => {
            self.tags.treeview.on('nodeselect', (item, count) => {
                self.selectedCount = count
                self.update()
            })
        })
