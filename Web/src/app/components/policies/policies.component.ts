import { Component } from '@angular/core';
import { fadeInOut } from '../../helpers/animations';
import { ConfigurationService } from '../../services/configuration.service';

@Component({
    selector: 'policies',
    templateUrl: './policies.component.html',
  styleUrls: ['./policies.component.scss'],
  animations: [fadeInOut]
})
export class PoliciesComponent {
  constructor(public configurations: ConfigurationService) {

    }
}
