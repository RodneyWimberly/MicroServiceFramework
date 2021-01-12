import { Component, OnInit, OnDestroy, Input } from '@angular/core';
import { AlertService, MessageSeverity, DialogType } from '../../services/alert.service';
import * as generated from '../../services/endpoint.services';
import { ConfigurationService } from '../../services/configuration.service';
import { Utilities } from '../../helpers/utilities';
import { AuthProviders, UserLoginModel } from '../../models/user-login.model';
import { Observable, Subject } from 'rxjs';
import { ModalDirective } from 'ngx-bootstrap/modal';
import { AuthProvidersModel } from '../../models/enum.models';

export type LoginDialogOperations = "show" | "hide";

@Component({
  selector: 'login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.scss']
})
export class LoginComponent implements OnInit, OnDestroy {
  get authProvider(): AuthProvidersModel { return this.configurations.authProvider; }
  userLogin = new UserLoginModel();
  isLoading = false;
  formResetToggle = true;
  modalHideCallback: () => void;
  loginStatusSubscription: any;
  loginDialogOperations = new Subject<LoginDialogOperations>();
  @Input() isModal = false;

  constructor(private alertService: AlertService, private authEndpointService: generated.AuthEndpointService, private configurations: ConfigurationService) {

  }

  ngOnInit() {
    this.userLogin.rememberMe = this.authEndpointService.rememberMe;
    
    if (!this.shouldRedirect) {
      this.authEndpointService.redirectLoginUser();
    } else {
      this.loginStatusSubscription = this.authEndpointService.getLoginStatusEvent().subscribe(isLoggedIn => {
        if (!this.shouldRedirect) {
          this.authEndpointService.redirectLoginUser();
        }
      });
    }
  }


  ngOnDestroy() {
    if (this.loginStatusSubscription) {
      this.loginStatusSubscription.unsubscribe();
    }
  }

  get loginDialogOperationsEvent(): Observable<LoginDialogOperations> {
    return this.loginDialogOperations.asObservable();
  }

  get shouldRedirect() {
    return !this.isModal && this.authEndpointService.isLoggedIn && !this.authEndpointService.isSessionExpired;
  }


  showErrorAlert(caption: string, message: string) {
    this.alertService.showMessage(caption, message, MessageSeverity.error);
  }

  hideModal() {
    if (this.modalHideCallback) {
      this.modalHideCallback();
    }
  }

  async login(authProvider: AuthProvidersModel) {
    this.isLoading = true;
    this.hideModal();
    try {
      await this.authEndpointService.login(authProvider, this.userLogin.userName, this.userLogin.password, this.userLogin.rememberMe)
    }
    catch (error) {
      this.alertService.stopLoadingMessage();
      if (Utilities.checkNoNetwork(error)) {
        this.alertService.showStickyMessage(Utilities.noNetworkMessageCaption, Utilities.noNetworkMessageDetail, MessageSeverity.error, error);
        this.offerAlternateHost();
      } else {
        const errorMessage = Utilities.getHttpResponseMessage(error);

        if (errorMessage) {
          this.alertService.showStickyMessage('Unable to login', this.mapLoginErrorMessage(errorMessage), MessageSeverity.error, error);
        } else {
          this.alertService.showStickyMessage('Unable to login', 'An error occured whilst logging in, please try again later.\nError: ' + Utilities.getResponseBody(error), MessageSeverity.error, error);
        }
      }

      setTimeout(() => {
        this.isLoading = false;
      }, 500);
    }
  }

  offerAlternateHost() {

      if (Utilities.checkIsLocalHost(location.origin) && Utilities.checkIsLocalHost(this.configurations.webBaseUrl)) {
      this.alertService.showDialog('Dear Developer!\nIt appears your backend Web API service is not running...\n' +
        'Would you want to temporarily switch to the online Demo API below?(Or specify another)',
        DialogType.prompt,
        (value: string) => {
          this.configurations.webBaseUrl = value;
          this.alertService.showStickyMessage('API Changed!', 'The target Web API has been changed to: ' + value, MessageSeverity.warn);
        },
        null,
        null,
        null,
        this.configurations.fallbackBaseUrl);
    }
  }


  mapLoginErrorMessage(error: string) {

    if (error == 'invalid_username_or_password') {
      return 'Invalid username or password';
    }

    if (error == 'invalid_grant') {
      return 'This account has been disabled';
    }

    return error;
  }


  reset() {
    this.formResetToggle = false;

    setTimeout(() => {
      this.formResetToggle = true;
    });
  }

  
}
