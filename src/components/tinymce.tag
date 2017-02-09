// Без content_editable: true не работает как надо
tinymce
    .form-control(id='tmce{ _riot_id }', style='height: auto')

    script(type='text/babel').
        var self = this

        self.value = opts.content || ''
        self.hidden = false

        Object.defineProperty(self.root, 'value', {
            get: function () {
                return self.value
            },
            set: function (value) {
                self.value = value
            }
        });

        var setup = function (editor) {
            editor.on('change undo redo reset SaveContent ObjectResized', function (e) {
                $(self.root).trigger('change')
            })

            editor.on('init', function (args) {
                editor.setContent(self.value);
                Object.defineProperty(self, 'value', {
                    get: function () {
                        return editor.getContent()
                    },
                    set: function (value) {
                        if (value == null || value == undefined)
                            value = ''
                        editor.setContent(value)
                    }
                })
            })
        }

        var options = opts.options || {
            selector: '#tmce' + self._riot_id,
            //content_editable: true,
            inline: true,
            setup: setup,
            statusbar: false,
            autofocus: true,
            menubar: false,
            //document_base_url: "/",
            safari_warning: false,
            remove_script_host: false,
            convert_urls: false,
            theme: "modern",
            forced_root_block: false,
            browser_spellcheck: true,
            convert_fonts_to_spans: true,
            paste_data_images: true,
            // paste_word_valid_elements: "p,b,strong,i,em,h1,h2",
            paste_webkit_styles: "color",
            paste_merge_formats: true,
            table_grid: true,
            plugins: 'fullscreen advlist autolink table paste code',
            language: "ru",
            toolbar1: "undo redo | bold italic underline | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent",
            toolbar2: 'removeformat styleselect | table | code'
        }


        self.one('updated', function () {
            self.root.name = opts.name

            if (opts.options)
                opts.options.setup = setup

            tinymce.init(options)
        })