package main

import "testing"

func TestSum_ReturnVal(t *testing.T){
  const (
    a=4 
    b=5
    expected=9
   )
   actual:=Sum(a,b)
   if actual != expected {
    t.FatalNow()
   }
}
