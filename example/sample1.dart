
import 'package:simple_regexp/simple_regexp.dart';


void main(){

  String s = 'Date: 20140321' ;
  s = SimpleRegExp.replace(s, r'(\d\d\d\d)(\d\d)(\d\d)', r'year: $1 ; month: $2 ; day: $3') ;
  
  print(s) ;

  String numb = '111 222333 44' ; 
  numb = SimpleRegExp.formatMask(numb, 'ddd.ddd.ddd-dd') ;
  
  print(numb) ;
  
  String cel = '123 5551234' ; 
  cel = SimpleRegExp.formatMask(cel, '(ddd) d+-dddd') ;
  
  print(cel) ;
  
  print( SimpleRegExp.formatMask('123', '(ddd) d+-dddd') ) ;
  print( SimpleRegExp.formatMask('123 55', '(ddd) d+-dddd') ) ;
  print( SimpleRegExp.formatMask('123 555', '(ddd) d+-dddd') ) ;
  print( SimpleRegExp.formatMask('123 55512', '(ddd) d+-dddd') ) ;
  print( SimpleRegExp.formatMask('123 5551234', '(ddd) d+-dddd') ) ;
  
}

