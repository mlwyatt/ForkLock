import { Application } from '@hotwired/stimulus';

/* This import has side-effects */
// eslint-disable-next-line import/no-unassigned-import
import 'trix';

const application = Application.start();

// Configure Stimulus development experience
application.debug = false;

declare global {
  interface Window {
    Stimulus: typeof application;
  }
}

window.Stimulus = application;

export { application };
