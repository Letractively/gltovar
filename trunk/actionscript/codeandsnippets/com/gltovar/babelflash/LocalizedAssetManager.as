package com.gltovar.babelflash 
{
	/**
	 * ...
	 * @author Louis Tovar
	 */
	public class LocalizedAssetManager
	{
		
		public function LocalizedAssetManager() 
		{
			_localizedAssets = new Array();
		}
		
		private var _localizedAssets:Array;
		
		public function addLocalizedAssetData(p_localizedAssetData:LocalizedAssetData):void
		{
			_localizedAssets[p_localizedAssetData.language + p_localizedAssetData.id] = p_localizedAssetData;
		}
		
		/**
		 * this is the main retrieval function, he id is the same id that the asset art has
		 * @param	p_localizedAssetId
		 * @param	p_language
		 * @return
		 */
		public function getLocalizedAssetDataFromId(p_localizedAssetId:String, p_language:String = null):LocalizedAssetData
		{
			var result:LocalizedAssetData;
			var language:String;
			
			language = (p_language) ? p_language : BabelFlash.instance.currentLanguage;
			
			var assetKey:String = language + p_localizedAssetId;
			
			result = getLocalizedAssetDataFromKey(assetKey);
			
			return result;
		}
		
		/**
		 * The key currently is the [language id] + [asset id]
		 * @param	p_localizedAssetKey
		 * @return
		 */
		public function getLocalizedAssetDataFromKey(p_localizedAssetKey:String):LocalizedAssetData
		{
			var result:LocalizedAssetData;
			
			if (_localizedAssets &&  p_localizedAssetKey in _localizedAssets)
			{
				result = _localizedAssets[p_localizedAssetKey];
			}
			else
			{
				throw Error('Did not find the asset with this key: ' + p_localizedAssetKey);
			}
			
			return result;
		}
		
	}

}