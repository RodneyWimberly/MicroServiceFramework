import { Component, Input, ContentChild, OnInit } from '@angular/core';
import { InputRefDirective } from '../../directives/input-ref.directive';
import { FormGroup } from '@angular/forms';
import { AppTranslationService } from '../../services/app-translation.service';

@Component({
    selector: 'validation-control',
    templateUrl: './validation-control.component.html',
    styleUrls: ['./validation-control.component.scss']
})
export class ValidationControlComponent implements OnInit {
  @Input()
  public isEditMode: boolean = true;

  @Input()
  public showValidationErrors: boolean = true;

  @Input()
  public showSeperator: boolean = true;

  @Input()
  public form: FormGroup;

  @Input()
  public translationKey: string;

  @ContentChild(InputRefDirective, { static: true })
  public input: InputRefDirective;

  constructor(private translationService: AppTranslationService) {
  }

  public ngOnInit() {
  }

  public get label(): string {
    return this.translationService.getTranslation(this.translationKey);
  }

  public get controlName(): string | number {
    return this.input.controlName;
  }

  public get controlValue(): any {
    return this.input.controlValue;
  }

  public get hasError(): boolean {
    return this.input.hasError;
  }

  public get errorMessages(): string[] {
    const messages: string[] = [];
    const errorKeys: string[] = Object.keys(this.input.errors);

    errorKeys.forEach(errorKey => {
      messages.push(this.translationService.getTranslation(this.translationKey + "Validations." + errorKey));
    });
    return messages;
  }
}
