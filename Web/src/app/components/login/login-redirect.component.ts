import { Component, OnDestroy, OnInit } from '@angular/core';
import { fadeInOut } from '../../helpers/animations';
import { AccountService } from '../../services/account.service';
import { ConfigurationService } from '../../services/configuration.service';
import { AuthEndpointService, UserViewModel } from '../../services/endpoint.services';

@Component({
  selector: 'login-redirect',
  templateUrl: './login-redirect.component.html',
  styleUrls: ['./login-redirect.component.scss'],
  animations: [fadeInOut]
})

export class LoginRedirectComponent implements OnInit, OnDestroy {
  constructor(private authService: AuthEndpointService, private accountService: AccountService, private configurations: ConfigurationService) {
  }

  ngOnInit(): void {
    this.authService.processImplicitFlowResponse().then((user: UserViewModel) => {
      //if (user)
        //this.accountService.getUser(user.id).subscribe((dbUser: UserViewModel) => {
         // if (!dbUser)
            //this.accountService.newUser(user);
        //});
    });
  }

  ngOnDestroy(): void {
  }
}
