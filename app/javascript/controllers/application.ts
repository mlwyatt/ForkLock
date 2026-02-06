import { Application } from '@hotwired/stimulus';

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
