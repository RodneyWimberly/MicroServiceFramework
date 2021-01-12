import { Directive } from '@angular/core';
import { NgControl, ValidationErrors } from '@angular/forms';

@Directive({
  selector: '[inputRef]'
})

export class InputRefDirective {
  constructor(private formControl: NgControl) {  }

  public get hasError(): boolean {
    return this.formControl.invalid;
  }

  public get errors(): ValidationErrors {
    if (this.hasError && this.formControl.errors) {
      return this.formControl.errors;
    }
    return null;
  }

  public get controlValue(): any {
    return this.formControl.value;
  }

  public get controlName(): string | number {
    return this.formControl.name;
  }
}
