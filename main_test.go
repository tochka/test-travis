package main

import "testing"

func TestSum_ReturnVal(t *testing.T){
  const (
    a=4 
    b=5
    expected=9
   )
   actual:=sum(a,b)
   if actual != expected {
    t.FailNow()
   }
}
