package starling.display
{
    import flash.geom.Matrix;
    import flash.utils.Dictionary;

    import starling.core.RenderSupport;
    import starling.filters.FragmentFilter;

    /**
     * Container for LayeredObjects. It displays only those
     * DisplayObjects that are linked to existing layer within
     * some LayeredObject.
     *
     * @author Vladimir Atamanov
     */
    public class LayeredContainer extends DisplayObjectContainer
    {
        private static const LIST_OBJECTS_POOL:Vector.<Vector.<ListObject>> = new Vector.<Vector.<ListObject>>();
        private static const HELPER_MATRIX:Matrix = new Matrix();

        private const _layers:Vector.<String> = new Vector.<String>();
        private const _listObjectsByName:Dictionary = new Dictionary();

        public function LayeredContainer()
        {
            super();
        }

        /**
         * Creates new layer on top of all others.
         * If layer with such name already exists then
         * nothing happens.
         */
        public function createLayer(layerName:String):void
        {
            var index:int = _layers.indexOf(layerName);
            if (index == -1)
            {
                _layers.push(layerName);
                var numChildren:int = this.numChildren;
                for (var i:int = 0; i < numChildren; ++i)
                {
                    var layeredObject:LayeredObject = getChildAt(i) as LayeredObject;
                    if (layeredObject != null)
                    {
                        var listObject:ListObject = layeredObject.getListObject(layerName);
                        if (listObject != null)
                            addListObject(listObject);
                    }
                }
            }
        }

        /**
         * Deletes layer. That does not remove
         * DisplayObjects from child LayeredObjects.
         */
        public function deleteLayer(layerName:String):void
        {
            var index:int = _layers.indexOf(layerName);
            if (index != -1)
            {
                var listObjects:Vector.<ListObject> = _listObjectsByName[layerName];
                if (listObjects != null)
                {
                    listObjects.length = 0;
                    LIST_OBJECTS_POOL.push(listObjects);
                    delete _listObjectsByName[layerName];
                }

                var length:int = _layers.length;
                for (var i:int = index + 1; i < length; ++i)
                    _layers[i - 1] = _layers[i];
                --_layers.length;
            }
        }

        /**
         * Checks if container has layer with specified name.
         */
        public function hasLayer(layerName:String):Boolean
        {
            return _layers.indexOf(layerName) != -1;
        }

        override public function render(support:RenderSupport, parentAlpha:Number):void
        {
            var alpha:Number = parentAlpha * this.alpha;
            var blendMode:String = support.blendMode;

            var numLayers:int = _layers.length;
            for (var i:int = 0; i < numLayers; ++i)
            {
                var layerName:String = _layers[i];
                var listObjects:Vector.<ListObject> = _listObjectsByName[layerName];
                if (listObjects == null)
                    continue;

                var numListObjects:int = listObjects.length;
                for (var j:int = 0; j < numListObjects; ++j)
                {
                    var listObject:ListObject = listObjects[j];
                    var layeredObject:LayeredObject = listObject.layeredObject;
                    if (layeredObject.hasVisibleArea)
                    {
                        var filter:FragmentFilter = layeredObject.filter;
                        support.pushMatrix();
                        support.prependMatrix(layeredObject.getTransformationMatrix(this, HELPER_MATRIX));
                        support.blendMode = layeredObject.blendMode;

                        var validAlpha:Number = alpha * layeredObject.getAlphaBeforeContainer();
                        if (filter != null)
                            filter.render(listObject, support, validAlpha);
                        else
                            listObject.render(support, validAlpha);

                        support.blendMode = blendMode;
                        support.popMatrix();
                    }
                }
            }
        }

        override public function dispose():void
        {
            super.dispose();

            for (var layerName:String in _listObjectsByName)
            {
                var listObjects:Vector.<ListObject> = _listObjectsByName[layerName];
                listObjects.length = 0;
                LIST_OBJECTS_POOL.push(listObjects);
            }
        }

        internal function addListObject(listObject:ListObject):void
        {
            var listObjects:Vector.<ListObject> = _listObjectsByName[listObject.layerName];
            if (listObjects == null)
            {
                if (LIST_OBJECTS_POOL.length == 0)
                    listObjects = new Vector.<ListObject>();
                else
                    listObjects = LIST_OBJECTS_POOL.pop();
                _listObjectsByName[listObject.layerName] = listObjects;
            }

            listObjects.push(listObject);
        }

        internal function removeListObject(listObject:ListObject):void
        {
            var listObjects:Vector.<ListObject> = _listObjectsByName[listObject.layerName];
            var length:int = listObjects.length;
            var index:int = listObjects.indexOf(listObject);
            for (var i:int = index + 1; i < length; ++i)
                listObjects[i - 1] = listObjects[i];
            --listObjects.length;
            if (listObjects.length == 0)
            {
                LIST_OBJECTS_POOL.push(listObjects);
                delete _listObjectsByName[listObject.layerName];
            }
        }
    }
}