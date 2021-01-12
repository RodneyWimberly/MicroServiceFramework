import { Directive } from '@angular/core';
import { NG_VALIDATORS, Validator, ValidationErrors, FormGroup, AbstractControl } from '@angular/forms';


@Directive({
  selector: '[eventConditionsValue]',
  providers: [{ provide: NG_VALIDATORS, useExisting: EventConditionsValidatorDirective, multi: true }]
})
export class EventConditionsValidatorDirective implements Validator {
  onValidatorChange: () => void;

  validate(control: AbstractControl): ValidationErrors {
    var isValid: boolean = true;
    var errors: ValidationErrors = {
      'value': {
        'message': 'The field Value is required'
      }
    };

    var valueTexts: FormGroup = <FormGroup>control.get('valueText');
    isValid = valueTexts && Object.keys(valueTexts.controls).length > 0;
    if (isValid) {
      Object.keys(valueTexts.controls).forEach((value: string) => 
        isValid = isValid && valueTexts.controls[value].valid);
    }
    return isValid ? null : errors;
  }

  registerOnValidatorChange?(fn: () => void): void {
    this.onValidatorChange = fn;
  }
}
