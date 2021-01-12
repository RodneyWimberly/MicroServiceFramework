import { Component, ElementRef, OnInit, ViewChild } from '@angular/core';
import { fadeInOut } from '../../helpers/animations';
import { Router } from '@angular/router';
import { Utilities } from '../../helpers/utilities';

@Component({
    selector: 'landing-page',
    templateUrl: './landing-page.component.html',
  styleUrls: ['./landing-page.component.scss'],
  animations: [fadeInOut]
})
/** landing-page component*/
export class LandingPageComponent implements OnInit {
  @ViewChild('loginRef', { static: true }) loginElement: ElementRef;
  auth2: any;
  constructor(private router: Router) {

  }

  ngOnInit() {
    this.googleSDK();
  }

  loginEmail() {
    this.router.navigate(['/login']);
  }

  loginMicrosoft() {

  }

  loginGoogle() {
    let loginUrl = "https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=120435867455-8f37jhdhjbakph7qgvabporq6vmn0d98.apps.googleusercontent.com&scope=https://www.googleapis.com/auth/userinfo.profile%20https://www.googleapis.com/auth/userinfo.email%20https://www.googleapis.com/auth/userinfo.email&access_type=offline&approval_prompt=auto&redirect_uri=https://em-web.azurewebsites.net/login";
  }

  loginFacebook() {

  }

  prepareLoginButton() {

    this.auth2.attachClickHandler(this.loginElement.nativeElement, {},
      (googleUser) => {

        let profile = googleUser.getBasicProfile();
        console.log('Token || ' + googleUser.getAuthResponse().id_token);
        console.log('ID: ' + profile.getId());
        console.log('Name: ' + profile.getName());
        console.log('Image URL: ' + profile.getImageUrl());
        console.log('Email: ' + profile.getEmail());
        //YOUR CODE HERE


      }, (error) => {
        alert(JSON.stringify(error, undefined, 2));
      });

  }

  googleSDK() {

    window['googleSDKLoaded'] = () => {
      window['gapi'].load('auth2', () => {
        this.auth2 = window['gapi'].auth2.init({
          client_id: '120435867455-8f37jhdhjbakph7qgvabporq6vmn0d98.apps.googleusercontent.com',
          cookiepolicy: 'single_host_origin',
          scope: 'profile email openid',
          response_type: 'code',
          access_type: 'offline',
          approval_prompt: 'auto',
          redirect_uri: 'https://em-web.azurewebsites.net/login'
        });
        this.prepareLoginButton();
      });
    }

    (function (d, s, id) {
      var js, fjs = d.getElementsByTagName(s)[0];
      if (d.getElementById(id)) { return; }
      js = d.createElement(s); js.id = id;
      js.src = "https://apis.google.com/js/platform.js?onload=googleSDKLoaded";
      fjs.parentNode.insertBefore(js, fjs);
    }(document, 'script', 'google-jssdk'));

  }
}
