import { NgModule, Injectable } from '@angular/core';
import { Routes, RouterModule, DefaultUrlSerializer, UrlSerializer, UrlTree } from '@angular/router';

import { LoginComponent } from './components/login/login.component';
import { LandingPageComponent } from './components/login/landing-page.component';
import { HomeComponent } from './components/home/home.component';
import { ExtendedLogsComponent } from './components/extended-logs/extended-logs.component';
import { SettingsComponent } from './components/settings/settings.component';
import { AboutComponent } from './components/about/about.component';
import { NotFoundComponent } from './components/not-found/not-found.component';
import * as generated from './services/endpoint.services';
import { AuthGuardService} from './services/auth-guard.service';
import { Utilities } from './helpers/utilities';
import { PoliciesComponent } from './components/policies/policies.component';
import { LoginRedirectComponent } from './components/login/login-redirect.component';



@Injectable()
export class LowerCaseUrlSerializer extends DefaultUrlSerializer {
  parse(url: string): UrlTree {
    const possibleSeparators = /[?;#]/;
    const indexOfSeparator = url.search(possibleSeparators);
    let processedUrl: string;

    if (indexOfSeparator > -1) {
      const separator = url.charAt(indexOfSeparator);
      const urlParts = Utilities.splitInTwo(url, separator);
      urlParts.firstPart = urlParts.firstPart.toLowerCase();

      processedUrl = urlParts.firstPart + separator + urlParts.secondPart;
    } else {
      processedUrl = url.toLowerCase();
    }

    return super.parse(processedUrl);
  }
}


const routes: Routes = [
    { path: '', component: HomeComponent, canActivate: [AuthGuardService], data: { title: 'Home' } },
    { path: 'callback', component: LoginRedirectComponent, data: { title: 'Login Redirect' } },
    { path: 'login', component: LoginComponent, data: { title: 'Login' } },
    { path: 'policies', component: PoliciesComponent, data: { title: 'Policies' } },
    { path: 'logs', component: ExtendedLogsComponent, canActivate: [AuthGuardService], data: { title: 'Logs' } },
    { path: 'settings', component: SettingsComponent, canActivate: [AuthGuardService], data: { title: 'Settings' } },
    { path: 'about', component: AboutComponent, data: { title: 'About Us' } },
    { path: 'home', redirectTo: '/', pathMatch: 'full' },
    { path: '**', component: NotFoundComponent, data: { title: 'Page Not Found' } }
];


@NgModule({
  imports: [RouterModule.forRoot(routes, { relativeLinkResolution: 'legacy' })],
  exports: [RouterModule],
  providers: [
    generated.AuthEndpointService,
    AuthGuardService,
    { provide: UrlSerializer, useClass: LowerCaseUrlSerializer }]
})
export class AppRoutingModule { }
