library simple_regexp;

typedef String ReplaceFunction(Match match) ;

class SimpleRegExp {
  
  static Map<String,RegExp> _re_cache = {} ;
  static Map<String,RegExp> _re_cache_m = {} ;
  static Map<String,RegExp> _re_cache_c = {} ;
  static Map<String,RegExp> _re_cache_mc = {} ;
  
  static Map<String,RegExp> _getRegExpCache(bool multiLine , bool caseSensitive) {

    if ( multiLine && caseSensitive ) {
      return _re_cache_mc ;
    }
    else if ( multiLine ) {
      return _re_cache_m ;
    }
    else if ( caseSensitive ) {
      return _re_cache_c ;
    }
    else {
      return _re_cache ;
    }
    
    throw new StateError('') ;
  }
  
  static void clearRegExpCache() {
    _re_cache.clear() ;
    _re_cache_m.clear() ;
    _re_cache_c.clear() ;
    _re_cache_mc.clear() ;
  }
  
  static void removeFromAllRegExpCaches(String pattern) {
    _re_cache.remove(pattern) ;
    _re_cache_m.remove(pattern) ;
    _re_cache_c.remove(pattern) ;
    _re_cache_mc.remove(pattern) ;
  }
  
  static RegExp removeFromRegExpCache(String pattern, {bool multiLine: false, bool caseSensitive: true}) {
        Map<String,RegExp> cache = _getRegExpCache(multiLine, caseSensitive) ;
        return cache.remove(pattern) ;
    }
  
  static RegExp buildCachedRegExp(String pattern, {bool multiLine: false, bool caseSensitive: true}) {
    Map<String,RegExp> cache = _getRegExpCache(multiLine, caseSensitive) ;
    
    RegExp regexp = cache[pattern] ;
    
    if (regexp != null) return regexp ;
    
    regexp = new RegExp(pattern, multiLine: multiLine, caseSensitive: caseSensitive) ;
    
    cache[pattern] = regexp ;
    
    return regexp ;
  }
  
  static RegExp _REGEXP_match_group = new RegExp(r'(\$\d)', multiLine: true, caseSensitive: true) ;
  
  static ReplaceFunction buildReplaceFunction(String replaceStr) {
    Iterable<Match> ms = _REGEXP_match_group.allMatches(replaceStr) ;
    
    List parts = [] ;
    
    int cursor = 0 ;
    
    for (Match m in ms) {
      parts.add( replaceStr.substring(cursor, m.start) ) ;
      
      String g = m.group(1) ;
      int n = int.parse( g.substring(1) ) ;
      parts.add(n) ;
      
      cursor = m.end ;
    }
    
    parts.add( replaceStr.substring(cursor) ) ;
    
    ReplaceFunction funct = (Match match) {
      String s = '' ;
      
      for (var p in parts) {
        
        if (p is String) {
          String ps = p ;
          s += ps ;
        }
        else {
          int n = p ;
          
          s += match.group(n) ;
        }
      }
      
      return s ;
    };
    
    return funct ;
  }
  
  static String replace(String str, String pattern, String replace, {bool multiLine: false, bool caseSensitive: true}) {
    RegExp regexp = buildCachedRegExp(pattern, multiLine: multiLine, caseSensitive: caseSensitive) ;
    ReplaceFunction funct = buildReplaceFunction(replace) ;
    
    String s = str.replaceAllMapped(regexp, funct) ;
    return s ;
  }
  
  static Map<String , RegExp> _formatMask_cache_Re = {}  ;
  static Map<String , RegExp> _formatMask_cache_ReNotAllowed = {}  ;
  static Map<String , ReplaceFunction> _formatMask_cache_ReplaceFunction = {}  ;
  
  static void clearFormatMaskCache() {
    _formatMask_cache_Re.clear() ;
    _formatMask_cache_ReNotAllowed.clear() ;
    _formatMask_cache_ReplaceFunction.clear() ;
  }
  
  static void removeFromFormatMaskCache(String mask) {
      _formatMask_cache_Re.remove(mask) ;
      _formatMask_cache_ReNotAllowed.remove(mask) ;
      _formatMask_cache_ReplaceFunction.remove(mask) ;
    }
  
  static String formatMask(String str, String mask) {
    
    RegExp re ;
    RegExp reNotAllowed ;
    ReplaceFunction funct ;
    
    re = _formatMask_cache_Re[mask] ;
    
    if (re != null) {
      reNotAllowed = _formatMask_cache_ReNotAllowed[mask] ;
      funct = _formatMask_cache_ReplaceFunction[mask] ;
    }
    else {
      Iterable<Match> ms = _REGEXP_NON_MAKS.allMatches(mask) ;
      
      Map<String,bool> types = {} ;
      
      List<String> parts = [] ;
      List<String> partsRe = [] ;
      List<int> partsType = [] ;
      
      int cursor = 0 ;
      int groupCount = 0 ;
      
      for (Match m in ms) {
        String prev = mask.substring(cursor, m.start) ;
        
        if ( prev.isNotEmpty ) {
          parts.add(prev) ;
          partsRe.add( _maskAsRE(prev, types) ) ;
          partsType.add(++groupCount) ;
        }
        
        String g = m.group(1) ;
        
        parts.add(g) ;
        partsRe.add('') ;
        partsType.add(0) ;
        
        cursor = m.end ;
      }
      
      {
        String prev = mask.substring(cursor) ;
        
        if ( prev.isNotEmpty ) {
          parts.add(prev) ;
          partsRe.add( _maskAsRE(prev, types) ) ;
          partsType.add(++groupCount) ;
        }
      }
      
      String reNotAllowedStr = '' ;
      
      for ( String t in types.keys ) {
        reNotAllowedStr += t ;
      }
      
      reNotAllowedStr = "[^$reNotAllowedStr]+" ;
      
      reNotAllowed = new RegExp(reNotAllowedStr, multiLine: true, caseSensitive: true) ;
      
      String reStr = r'^' +  partsRe.join('') + r'$';
      
      re = new RegExp(reStr , multiLine: true, caseSensitive: true) ;
      
      funct = (Match match) {
        String s = '' ;
        int addedGroup = -1 ;
        
        for (int i = 0 ; i < partsType.length; i++) {
          int pGroup = partsType[i] ;
          
          if (pGroup > 0) {
            String g = match.group(pGroup) ;
            
            if (g.isNotEmpty) {
              if (i > 0) {
                
                for (int j = addedGroup+1 ; j < i ; j++) {
                  int pG = partsType[j] ;
                  
                  if (pG == 0) {
                    s += parts[j] ;
                    addedGroup = j ;
                  }
                }
              }
              
              s += g ;
            }
          }
        }
        
        return s ;
      };
      
      _formatMask_cache_Re[mask] = re ;
      _formatMask_cache_ReNotAllowed[mask] = reNotAllowed ;
      _formatMask_cache_ReplaceFunction[mask] = funct ;
    }
    
    str = str.replaceAll(reNotAllowed, '') ;
    
    return str.replaceAllMapped(re, funct) ;
  }
  

  static RegExp _REGEXP_NON_MAKS = new RegExp(r'([^dlw\+]+)', multiLine: true, caseSensitive: true) ;
  
  static String _maskAsRE(String mask , Map<String,bool> types) {
    String re = '' ;
    
    for (int i = 0 ; i < mask.length ; i++) {
      String c = mask.substring(i, i+1) ;
      String cNext = i < mask.length-1 ? mask.substring(i+1, i+2) : null ;
      
      if (c == '+') continue ;
      
      if (c == 'd') {
        re += r'\d' ;
        types[r'\d'] = true ;
      }
      else if (c == 'l') {
        re += r'[a-zA-Z]' ;
        types[r'a-zA-Z'] = true ;
      }
      else if (c == 'w') {
        re += r'\w' ;
        types[r'\w'] = true ;
      }
      
      if (cNext != null && cNext == '+') {
        re += '+?' ;
      }
      else {
        re += '?' ;
      }
      
    }
    
    return "($re)" ;
  }
  
}

  
  