"use strict";

export const imul = function(a) {
  return function(b) {
    return Math.imul(a, b);
  }
}
