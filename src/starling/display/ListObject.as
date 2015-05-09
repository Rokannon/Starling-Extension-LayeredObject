package starling.display
{
    import flash.geom.Rectangle;

    import starling.core.RenderSupport;
    import starling.filters.FragmentFilter;

    /**
     * Internal object that holds together list
     * of DisplayObjects in some LayeredObject
     * linked to a single layer. Extends DisplayObject
     * in order to be passed to FragmentFilter.
     *
     * @author Vladimir Atamanov
     */
    internal class ListObject extends DisplayObject
    {
        private static const helperRectangle:Rectangle = new Rectangle();

        public const list:Vector.<DisplayObject> = new <DisplayObject>[];
        public var layerName:String;
        public var layeredObject:LayeredObject;

        public function ListObject()
        {
            super();
        }

        override public function render(support:RenderSupport, parentAlpha:Number):void
        {
            if (layeredObject.clipRect != null)
            {
                var clipRect:Rectangle = support.pushClipRect(layeredObject.getClipRect(layeredObject.stage,
                    helperRectangle));
                if (clipRect.isEmpty())
                {
                    support.popClipRect();
                    return;
                }
            }

            var alpha:Number = parentAlpha * layeredObject.alpha;
            var blendMode:String = support.blendMode;

            var length:int = list.length;
            for (var i:int = 0; i < length; ++i)
            {
                var displayObject:DisplayObject = list[i];
                if (displayObject.hasVisibleArea)
                {
                    var filter:FragmentFilter = displayObject.filter;
                    support.pushMatrix();
                    support.transformMatrix(displayObject);
                    support.blendMode = displayObject.blendMode;

                    if (filter != null)
                        filter.render(displayObject, support, alpha);
                    else
                        displayObject.render(support, alpha);

                    support.blendMode = blendMode;
                    support.popMatrix();
                }
            }

            if (layeredObject.clipRect != null)
                support.popClipRect();
        }
    }
}