fileupload
    .form-group
        .form-inline
            .input-group(class='btn btn-primary { disabled: files.length >= opts.limit  }')
                input(onchange='{ add }', type='file', multiple='multiple', accept='{ opts.accept }',
                disabled='{ files.length >= opts.limit }')
                | Добавить
            button.btn.btn-danger(onclick='{ reset }', type='button') Сброс
    .form-inline
        .file.m-r-1(each='{ file, i in files }')
            .file-body
                span.remove(onclick='{ remove }') &times;
                fileupload-file(file='{ file }')
                p(title='{ file.name }') { file.name }

    style(scoped).
        input[type='file'] {
            position: absolute;
            top: 0;
            right: 0;
            width: 100%;
            opacity: 0;
            height: 100%;
            z-index: 5;
            cursor: pointer;
        }

        .file {
            display: inline-block;
            padding: 4px;
            border: 1px solid #ccc;
            border-radius: 4px;
            overflow: hidden;
            max-width: 128px;
            max-height: 148px;
        }

        .file-body {
            max-width: 120px;
            max-height: 140px;
            overflow: hidden;
            position: relative;
        }

        .file-body .remove {
            position: absolute;
            cursor: pointer;
            color: red;
            top: 0;
            right: 0;
            font-size: 25px;
            line-height: 0.5;
            font-weight: bold;
            text-shadow: 0 1px 0 black;
            display: none;
        }

        .file-body:hover .remove {
            display: block;
        }

        .file-body p {
            font-size: 10px;
            margin: 0;
            white-space: nowrap;
        }

    script(type='text/babel').
        var self = this

        opts.limit = opts.limit || 30

        self.files = []

        Object.defineProperty(self.root, 'value', {
            get: function () {
                return self.files
            }
        })

        function getUID (file) {
            return file.lastModified + file.name + file.size + file.type
        }

        function inFileList(file) {
            var uid = getUID(file);
            for (var i = 0; i < self.files.length; i++) {
                if (getUID(self.files[i]) == uid) {
                    return true
                }
            }
            return false
        }

        self.add = function (e) {
            for (var i = 0; i < e.target.files.length; i++) {
                if (!inFileList(e.target.files[i]) && (self.files.length < parseInt(opts.limit))) {
                    self.files.push(e.target.files[i])
                }
            }
            e.target.value = ''
        }

        self.reset = function () {
            self.files = []
        }

        self.remove = function (e) {
            self.files.splice(e.item.i, 1)
        }

fileupload-file
    canvas(width='120px', height='120px')

    script.
        var self = this,
            file = opts.file

        // Дает хорошее качество при уменьшении изображения в канвасе
        function resample_hermite(canvas, W, H, W2, H2) {
            W2 = Math.round(W2)
            H2 = Math.round(H2)
            var img = canvas.getContext("2d").getImageData(0, 0, W, H)
            var img2 = canvas.getContext("2d").getImageData(0, 0, W2, H2)
            var data = img.data
            var data2 = img2.data
            var ratio_w = W / W2
            var ratio_h = H / H2
            var ratio_w_half = Math.ceil(ratio_w / 2)
            var ratio_h_half = Math.ceil(ratio_h / 2)

            for (var j = 0; j < H2; j++) {
                for (var i = 0; i < W2; i++) {
                    var x2 = (i + j * W2) * 4
                    var weight = 0
                    var weights = 0
                    var weights_alpha = 0
                    var gx_r = gx_g = gx_b = gx_a = 0
                    var center_y = (j + 0.5) * ratio_h
                    for (var yy = Math.floor(j * ratio_h); yy < (j + 1) * ratio_h; yy++) {
                        var dy = Math.abs(center_y - (yy + 0.5)) / ratio_h_half
                        var center_x = (i + 0.5) * ratio_w
                        var w0 = dy * dy //pre-calc part of w
                        for (var xx = Math.floor(i * ratio_w); xx < (i + 1) * ratio_w; xx++) {
                            var dx = Math.abs(center_x - (xx + 0.5)) / ratio_w_half
                            var w = Math.sqrt(w0 + dx * dx)
                            if (w >= -1 && w <= 1) {
                                //hermite filter
                                weight = 2 * w * w * w - 3 * w * w + 1
                                if (weight > 0) {
                                    dx = 4 * (xx + yy * W)
                                    //alpha
                                    gx_a += weight * data[dx + 3]
                                    weights_alpha += weight
                                    //colors
                                    if (data[dx + 3] < 255)
                                        weight = weight * data[dx + 3] / 250
                                    gx_r += weight * data[dx]
                                    gx_g += weight * data[dx + 1]
                                    gx_b += weight * data[dx + 2]
                                    weights += weight
                                }
                            }
                        }
                    }
                    data2[x2] = gx_r / weights
                    data2[x2 + 1] = gx_g / weights
                    data2[x2 + 2] = gx_b / weights
                    data2[x2 + 3] = gx_a / weights_alpha
                }
            }
            canvas.getContext("2d").clearRect(0, 0, Math.max(W, W2), Math.max(H, H2))
            canvas.width = W2
            canvas.height = H2
            canvas.getContext("2d").putImageData(img2, 0, 0)
        }

        function drawCenterImage (ctx, img) {
            var iheight = img.naturalHeight,
                iwidth = img.naturalWidth,
                cheight = ctx.canvas.height,
                cwidth = ctx.canvas.width

            //ctx.canvas.width = iwidth
            //ctx.canvas.height = iheight

            var sx, sy, sWidth, sHeight

            if (iheight > iwidth) {
                sx = 0
                sy = parseInt((iheight - iwidth) / 2)
                sWidth = iwidth
                sHeight = iwidth
            } else {
                sy = 0;
                sx = parseInt((iwidth - iheight) / 2)
                sWidth = iheight
                sHeight = iheight
            }
            ctx.drawImage(img, sx, sy, sWidth, sHeight, 0, 0, cwidth, cheight)
            //resample_hermite(ctx.canvas, iwidth, iheight, cwidth, cheight)
        }

        self.on('mount', function () {
            var reader = new FileReader()

            reader.onload = function (file) {
                var img = document.createElement('img')
                img.src = file.target.result
                img.onload = function () {
                    img.onload = null
                    var canvas = self.root.getElementsByTagName('canvas')[0]
                    var ctx = canvas.getContext('2d')
                    drawCenterImage(ctx, img)
                }
            }
            reader.readAsDataURL(file)
        })