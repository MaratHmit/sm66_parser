var permissions = {
    isAdmin() {
        return app.config.isAdmin || false
    },
    checkMask(mask, objectMask) {
        mask = parseInt(mask.toString(), 2)
        objectMask = parseInt(objectMask.toString())
        return (mask & objectMask) === mask
    },
    checkPermission(object, mask) {
        let p = app.permissions || {}
        if (this.isAdmin() || !(object in p)) {
            return true
        } else {
            return this.checkMask(mask, p[object])
        }
    },
    permission(f, object, mask) {
        return this.checkPermission(object, mask) ? f : undefined
    }
}

riot.mixin('permissions', permissions)