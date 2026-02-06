import { Controller } from '@hotwired/stimulus';
import { typedController } from '@scripts/mixins/typescript_stimulus';

const targets = {
  card: HTMLElement,
  nopeIndicator: HTMLElement,
  likeIndicator: HTMLElement,
};
const values = {
  href: String,
  sessionCode: String,
};

export default class extends typedController(Controller<HTMLElement>, { targets, values }) {
  private startX = 0;
  private startY = 0;
  private currentX = 0;
  private isDragging = false;
  private readonly threshold = 100;

  left(): void {
    this.animateAndSubmit('left', false);
  }

  right(): void {
    this.animateAndSubmit('right', true);
  }

  connect(): void {
    this.bindEvents();
  }

  private bindEvents(): void {
    const self = this;
    const card = self.cardTarget;

    card.addEventListener('mousedown', self.onStart.bind(self));
    document.addEventListener('mousemove', self.onMove.bind(self));
    document.addEventListener('mouseup', self.onEnd.bind(self));

    card.addEventListener('touchstart', self.onStart.bind(self), { passive: true });
    document.addEventListener('touchmove', self.onMove.bind(self), { passive: false });
    document.addEventListener('touchend', self.onEnd.bind(self));
  }

  private onStart(evt: MouseEvent | TouchEvent): void {
    this.isDragging = true;
    this.cardTarget.classList.add('swiping');

    const point = 'touches' in evt ? evt.touches[0] : evt;

    if ( typeof point === 'undefined' ) {
      return;
    }

    this.startX = point.clientX;
    this.startY = point.clientY;
  }

  private onMove(evt: MouseEvent | TouchEvent): void {
    const self = this;

    if ( !self.isDragging ) return;

    evt.preventDefault();

    const point = 'touches' in evt ? evt.touches[0] : evt;

    if ( typeof point === 'undefined' ) {
      return;
    }

    self.currentX = point.clientX - self.startX;

    const currentY = point.clientY - self.startY;
    const rotate = self.currentX * 0.1;

    self.cardTarget.style.transform = `translate(${self.currentX}px, ${currentY}px) rotate(${rotate}deg)`;

    if ( self.currentX < -50 ) {
      self.nopeIndicatorTarget.style.opacity = String(Math.min(1, Math.abs(self.currentX) / 100));
      self.likeIndicatorTarget.style.opacity = '0';
    }
    else if ( self.currentX > 50 ) {
      self.likeIndicatorTarget.style.opacity = String(Math.min(1, self.currentX / 100));
      self.nopeIndicatorTarget.style.opacity = '0';
    }
    else {
      self.nopeIndicatorTarget.style.opacity = '0';
      self.likeIndicatorTarget.style.opacity = '0';
    }
  }

  private onEnd(): void {
    const self = this;

    if ( !self.isDragging ) return;

    self.isDragging = false;
    self.cardTarget.classList.remove('swiping');

    if ( self.currentX < -self.threshold ) {
      self.animateAndSubmit('left', false);
    }
    else if ( self.currentX > self.threshold ) {
      self.animateAndSubmit('right', true);
    }
    else {
      self.resetCard();
    }
  }

  private animateAndSubmit(direction: 'left' | 'right', liked: boolean): void {
    const self = this;
    const card = self.cardTarget;

    card.classList.add(`swipe-${direction}`);
    card.addEventListener('animationend', () => {
      void self.submitSwipe(liked);
    }, { once: true });
  }

  private resetCard(): void {
    this.cardTarget.style.transform = '';
    this.nopeIndicatorTarget.style.opacity = '0';
    this.likeIndicatorTarget.style.opacity = '0';
  }

  private async submitSwipe(liked: boolean): Promise<void> {
    const { restaurantId } = this.cardTarget.dataset;
    const csrfToken = document.querySelector<HTMLMetaElement>('[name="csrf-token"]')?.content;
    const headers = new Headers();

    headers.set('Content-Type', 'application/json');
    headers.set('X-CSRF-Token', csrfToken ?? '');
    headers.set('Accept', 'text/vnd.turbo-stream.html');

    try {
      const response = await fetch(this.hrefValue, {
        method: 'POST',
        headers,
        body: JSON.stringify({
          // eslint-disable-next-line @typescript-eslint/naming-convention
          restaurant_id: restaurantId,
          liked,
        }),
      });

      if ( response.ok ) {
        const html = await response.text();
        const template = document.createElement('template');

        template.innerHTML = html;
        document.body.appendChild(template.content);
      }
    }
    catch {
      this.resetCard();
    }
  }
}
