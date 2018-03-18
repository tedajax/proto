require 'sprite'

ImageMngr = {}

function ImageMngr:new()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    obj.images = {}

    return obj
end

function ImageMngr:load(name, filename, props)
    local props = props or {}

    local filterMin = props.filterMin or props.filter or "nearest"
    local filterMax = props.filterMax or props.filter or "nearest"
    local wrapH = props.wrapH or props.wrap or "clamp"
    local wrapV = props.wrapV or props.wrap or "clamp"

    local img = love.graphics.newImage(filename)

    assert(img ~= nil, string.format("Failed to load image at file '%s'.", filename))

    img:setFilter(filterMin, filterMax)
    img:setWrap(wrapH, wrapV)

    assert(self.images[name] == nil, string.format("Image name '%s' already taken.", name))

    local w, h = img:getDimensions()
    self.images[name] = {
        image = img, width = w, height = h
    }

    return img
end

function ImageMngr:getImage(name)
    assert(self.images[name] ~= nil, string.format("Image with name '%s' does not exist.", name))
    return self.images[name].image
end

function ImageMngr:getDimensions(name)
    return self:getWidth(name), self:getHeight(name)
end

function ImageMngr:getWidth(name)
    return self.images[name].width
end

function ImageMngr:getHeight(name)
    return self.images[name].height
end

function ImageMngr:createSprite(name)
    assert(self.images[name] ~= nil, string.format("Image with name '%s' does not exist.", name))
    return Sprite:new(self:getImage(name))
end