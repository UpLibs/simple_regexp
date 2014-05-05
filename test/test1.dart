
import 'package:simple_regexp/simple_regexp.dart' ;

main() {
  
  String s = 'Date: 20140321' ;
  
  s = SimpleRegExp.replace(s, r'(\d\d\d\d)(\d\d)(\d\d)', r'year: $1 ; month: $2 ; day: $3') ;

  assert( s == 'Date: year: 2014 ; month: 03 ; day: 21' ) ;
 
  String date = '20140325' ;
  date = SimpleRegExp.formatMask(date, 'dddd/dd/dd') ;
  
  assert( date == '2014/03/25' ) ;
  
  String numb = '111 222333 44' ; 
  numb = SimpleRegExp.formatMask(numb, 'ddd.ddd.ddd-dd') ;
  
  assert( numb == '111.222.333-44' ) ;
  
  String cel = '123 5551234' ; 
  cel = SimpleRegExp.formatMask(cel, '(ddd) d+-dddd') ;
  
  assert( cel == '(123) 555-1234' ) ;
    
}
