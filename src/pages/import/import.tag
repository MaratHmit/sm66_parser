import
    h3 Импорт каталога товаров
    form(onchange='{ change }', onkeyup='{ change }')
        .row
            .col-md-3: .form-group
                label.control-label.label-warning Для импорта необходим формат файла Excel2007 с расширением XLSX
            .col-md-3: .form-group
                .input-group
                    input.form-control(name='fileName', value='{ item.fileName }', placeholder='Выберите файл',
                    disabled='true')
                    span.input-group-addon.btn-file.btn.btn-default(onchange='{ changeFile }')
                        input(name='file', type='file', , accept='.xlsx')
                        i.fa.fa-fw.fa-folder-open
        .row(if='{ enableImport }')
            .col-md-3: .form-group
                label.control-label.label-warning Наценки на закупочную цену товара
            .col-md-1: .form-group
                label.control-label Розничная цена
                input.form-control(name='retailPrice', type='number', value='{ item.retailPrice }')
            .col-md-1: .form-group
                label.control-label Корпорат. цена
                input.form-control(name='corporatePrice', type='number', value='{ item.corporatePrice }')
            .col-md-1: .form-group
                label.control-label Оптовая цена
                input.form-control(name='wholesalePrice', type='number', value='{ item.wholesalePrice }')
        .row(if='{ enableImport }')
            .col-md-3: .form-group
                label.control-label.label-warning Обновлять цены акционных товаров
            .col-md-1
                .checkbox-inline
                    label
                        input(type='checkbox', name='updatePrices', checked='{ (item.updatePrices) }')
        .row
            .col-md-3: .form-group
                button.btn.btn-primary(onclick='{ loadFile }', type='button', disabled='{ !enableImport }') Импорт
        .row(if='{ percentUpload > 0 }')
            .col-md-6
                #progress-upload.text-xs-center Загрузка файла…{ percentUpload } %
                progress.progress(value='{ percentUpload }', max='100', aria-describedby="progress-upload")
    .panel.panel-default(if='{ run }')
        .panel-heading Процесс парсинга запущен
        .panel-body
            .row(if='{ item.countRows > 0 }')
                .col-md-3: .form-group
                    label.control-label Прочитано строк
                    input.form-control(name='countRows', type='number', value='{ item.countRows }', readonly)
            .row(if='{ item.countRows > 0 }')
                .col-md-6
                    #progress-goods.text-xs-center Импорт товаров…{ percentGoods } %
                    progress.progress(value='{ percentGoods }', max='100', aria-describedby="progress-goods")
            .row(if='{ countImages > 0 }')
                .col-md-6
                    #progress-images.text-xs-center Загрузка картинок…{ percentImages } шт.
                    progress.progress(value='{ percentImages }', max='{ countImages }', aria-describedby="progress-images")
    .panel.panel-default(if='{ finish }')
        .panel-heading Парсинг завершен
        .panel-body
            .row
                .col-md-2: .form-group
                    label.control-label Обновлено
                    input.form-control(name='countUpdate', type='number', value='{ item.countUpdate }', readonly)
                .col-md-2: .form-group
                    label.control-label Добавлено
                    input.form-control(name='countInsert', type='number', value='{ item.countInsert }', readonly)
                .col-md-2: .form-group
                    label.control-label Всего
                    input.form-control(name='countAllGoods', type='number', value='{ item.countInsert + item.countUpdate }', readonly)
            .row
                h4 Список новых товаров
                table.table
                    thead
                        tr
                            th Артикул
                            th Наименование
                            th Цена закуп.
                            th Цена розн.
                            th Цена корп.
                            th Цена опт.
                    tbody
                        tr(each='{ goods }')
                            th
                                a(href="{ link }" target="_blank", title="Перейти в карточку товара") { article }
                            th
                                a(href="{ link }" target="_blank", title="Перейти в карточку товара") { name }
                            th { pricePurchase }
                            th { price }
                            th { priceOptCorp }
                            th { priceOpt }

    row(if='{ error }')
        .col-md-6
            label.control-label.label-danger При импорте произошла фатальная ошибка! Попробуйте повторно через 1 час.


    script(type='text/babel').
        var self = this

        self.item = {
            retailPrice: 100,
            corporatePrice: 50,
            wholesalePrice: 10,
            updatePrices: false
        }

        self.mixin('change')

        self.loader = false
        self.enableImport = false
        self.goods = []

        self.changeFile = (e) => {
            self.clear()
            self.item.fileName = e.target.files[0].name
            self.enableImport = true
            self.update()
        }

        self.loadFile = () => {
            self.clear()
            let formData = new FormData()
            let target = self.file

            formData.append('file', target.files[0])
            formData.append('retailPrice', self.item.retailPrice)
            formData.append('corporatePrice', self.item.corporatePrice)
            formData.append('wholesalePrice', self.item.wholesalePrice)
            formData.append('updatePrices', self.item.updatePrices)
            self.loader = true
            self.error = false
            self.update()

            API.upload({
                object: 'Import',
                data: formData,
                progress(e) {
                    self.percentUpload = Math.ceil(e.loaded / e.total * 100)
                    self.update()
                },
                success(response) {
                    self.item.fileName = response.fileName
                    self.item.cmd = "count"
                    self.importGoods()
                },
                complete() {
                    self.loader = false
                    self.update()
                },
                error() {
                    console.log("1")
                    self.clear()
                    self.enableImport = true
                    self.error = true
                    self.update()
                }
            })
        }

        self.importGoods = () => {
            self.run = true
            self.update()

            API.request({
                object: 'Import',
                method: 'Exec',
                data: self.item,
                success(response) {
                    if (self.item.cmd == "count") {
                        self.item.countRows = response.countRows
                        self.percentGoods = 0
                        self.percentImages = 0
                        self.item.cmd = "run"
                    } else if (self.item.cmd == "run") {
                        self.percentGoods = response.percentGoods
                        if (self.percentGoods == 100) {
                            self.countImages = response.countImages
                            self.item.countInsert = response.countInsert
                            self.item.countUpdate = response.countUpdate
                        }
                    }
                },
                complete() {
                    if (self.item.cmd == "run" && self.percentGoods < 100) {
                        self.importGoods()
                    } else {
                        if (self.countImages) {
                            self.item.cmd = "images"
                            self.importImages()
                        }
                        else {
                            self.enableImport = true
                            self.report()
                        }
                    }
                    self.update()
                },
                error() {
                    self.clear()
                    self.enableImport = true
                    self.error = true
                    self.update()
                }
            })
        }

        self.importImages = () => {
            API.request({
                object: 'Import',
                method: 'Image',
                data: self.item,
                success(response) {
                    self.percentImages = response.percentImages
                },
                complete() {
                    if (self.percentImages < self.countImages)
                        self.importImages()
                    else self.report()
                    self.update()
                },
                error() {
                    self.clear()
                    self.enableImport = true
                    self.error = true
                    self.update()
                }
            })
        }

        self.report = () => {
            self.finish = true
            self.update()

            API.request({
                object: 'Import',
                method: 'Report',
                success(response) {
                    self.goods = response.goods
                },
                complete() {
                    self.update()
                }
            })
        }

        self.clear = () => {
            self.loader = false
            self.item.cmd = null
            self.item.countRows = 0
            self.item.countUpdate = 0
            self.item.countInsert = 0
            self.countImages = 0
            self.run = false
            self.percentGoods = 0
            self.percentImages = 0
            self.percentUpload = 0
            self.enableImport = false
            self.finish = false
        }

        self.newImport = () => {
            self.clear()
            self.update()
        }

        self.on('mount', () => {
            self.newImport()
        })

        observable.on('import-start', () => {
            self.newImport()
        })