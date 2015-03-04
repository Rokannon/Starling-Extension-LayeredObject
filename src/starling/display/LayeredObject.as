package starling.display
{
    import flash.utils.Dictionary;

    /**
     * Object that holds together several DisplayObjects on
     * different layers. Order of display depends on parent
     * LayeredContainer.
     *
     * @author Vladimir Atamanov
     */
    public class LayeredObject extends DisplayObjectContainer
    {
        private static const LIST_OBJECT_POOL:Vector.<ListObject> = new Vector.<ListObject>();

        private const _listObjects:Vector.<ListObject> = new Vector.<ListObject>();
        private const _listObjectByName:Dictionary = new Dictionary();
        private const _listObjectByDisplayObject:Dictionary = new Dictionary();
        private const _layeredDisplayObjects:Vector.<DisplayObject> = new Vector.<DisplayObject>();

        private var _container:LayeredContainer;

        public function LayeredObject()
        {
            super();
        }

        /**
         * Add DisplayObject and link it to layer.
         */
        public function addChildToLayer(displayObject:DisplayObject, layerName:String):void
        {
            if (displayObject.parent != this)
            {
                var listObject:ListObject = _listObjectByName[layerName];
                if (listObject == null)
                {
                    if (LIST_OBJECT_POOL.length == 0)
                        listObject = new ListObject();
                    else
                        listObject = LIST_OBJECT_POOL.pop();
                    listObject.layerName = layerName;
                    listObject.layeredObject = this;
                    _listObjects.push(listObject);
                    if (_container != null)
                        _container.addListObject(listObject);
                }

                listObject.list.push(displayObject);
                _listObjectByDisplayObject[displayObject] = listObject;
                _layeredDisplayObjects.push(displayObject);
            }
            addChild(displayObject);
        }

        override public function removeChildAt(index:int, dispose:Boolean = false):DisplayObject
        {
            var displayObject:DisplayObject = super.removeChildAt(index, dispose);

            var length:int;
            var i:int;

            var listObject:ListObject = _listObjectByDisplayObject[displayObject];
            if (listObject != null)
            {
                delete _listObjectByDisplayObject[displayObject];

                // Remove from display objects.
                length = _layeredDisplayObjects.length;
                index = _layeredDisplayObjects.indexOf(displayObject);
                for (i = index + 1; i < length; ++i)
                    _layeredDisplayObjects[i - 1] = _layeredDisplayObjects[i];
                --_layeredDisplayObjects.length;

                var list:Vector.<DisplayObject> = listObject.list;

                // Remove from list object.
                length = list.length;
                index = list.indexOf(displayObject);
                for (i = index + 1; i < length; ++i)
                    list[i - 1] = list[i];
                --list.length;

                // Return to pool if necessary.
                if (list.length == 0)
                {
                    if (_container != null)
                        _container.removeListObject(listObject);
                    listObject.layerName = null;
                    listObject.layeredObject = null;
                    LIST_OBJECT_POOL.push(listObject);
                    length = _listObjects.length - 1;
                    index = _listObjects.indexOf(listObject);
                    _listObjects[index] = _listObjects[length];
                    _listObjects.length = length;
                }
            }

            return displayObject;
        }

        override public function dispose():void
        {
            super.dispose();

            while (_listObjects.length != 0)
            {
                var listObject:ListObject = _listObjects.pop();
                listObject.layerName = null;
                listObject.layeredObject = null;
                listObject.list.length = 0;
                LIST_OBJECT_POOL.push(listObject);
            }
        }

        override internal function setParent(value:DisplayObjectContainer):void
        {
            var container:LayeredContainer = value as LayeredContainer;
            for each (var listObject:ListObject in _listObjects)
            {
                if (_container != null)
                    _container.removeListObject(listObject);
                if (container != null)
                    container.addListObject(listObject);
            }
            _container = container;

            super.setParent(value);
        }

        internal function getListObject(layerName:String):ListObject
        {
            return _listObjectByName[layerName];
        }
    }
}