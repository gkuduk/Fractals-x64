#include <stdio.h>
#include <stdlib.h>
#include <allegro5/allegro.h>
#include <allegro5/allegro_primitives.h>
#include <allegro5/allegro_image.h>
#ifdef __cplusplus
extern "C" {
#endif
 void julia(char *a, int iter, double cx, double cy, double l, double r, double b, double t);
#ifdef __cplusplus
}
#endif


int main(int argc, char *argv[])
{
  char* table;
  int iter;
 
  double cx, cy, l, r, b, t;

  table = malloc(786432*sizeof(char));


  if(table == NULL)
  {
	printf("Malloc error!\n");
	return 1;
  }

  iter = atoi(argv[1]);

  if(iter > 255) iter = 255;

  cx = atof(argv[2]);
  cy = atof(argv[3]);

  l = -2.5;
  r = 2.5;

  b = -2.5;
  t = 2.5;

  printf("x64 Julia set for %f %f with %d iterations\n", cx, cy, iter);

  // allegro stuff
  int width = 512;
  int height = 512;
  int done = 0;

  ALLEGRO_DISPLAY *display = NULL;
  ALLEGRO_EVENT_QUEUE *event_queue = NULL;

  if(!al_init())		//initialize allegro
	return -1;

  display = al_create_display(width, height);

  if(!display)
	return -1;

  al_install_keyboard();
  al_install_mouse();
  al_init_image_addon();

  al_get_backbuffer(display);

  event_queue = al_create_event_queue();
  al_register_event_source(event_queue, al_get_mouse_event_source());
  al_register_event_source(event_queue, al_get_keyboard_event_source());

  julia(table, iter, cx, cy, l, r, b, t);

  char red, green, blue;

  int k = 0;
  for(int i = 0; i < 512; i++)
  {
	for(int j = 0; j < 512; j++)
	{
		red = table[k];
		red = red - '0';
		green = table[k+1];
		green = green - '0';
		blue = table[k+2];
		blue = blue - '0';
		al_put_pixel(j, i,al_map_rgb(red, green, blue));
		k=k+3;
	}
  }
  k = 0;

  double temp1, temp2, midx, midy;
  double zoom = 4;

  while(!done)
  {
	ALLEGRO_EVENT ev;
	al_wait_for_event(event_queue, &ev);

	if(ev.type == ALLEGRO_EVENT_KEY_DOWN)
	{
		switch(ev.keyboard.keycode)
		{
			case ALLEGRO_KEY_ESCAPE:
				done = 1;
				break;
		}
	}

	if(ev.type == ALLEGRO_EVENT_MOUSE_BUTTON_DOWN)
	{
		if(ev.mouse.button == 1)
		{
			temp1 = (r-l)/width;
			temp2 = (t-b)/height;
			midx = ev.mouse.x*temp1 + l;
			midy = ev.mouse.y*temp2 + b;
			
			l = midx-((r-l)/zoom);
			r = midx+((r-l)/zoom);
			b = midy-((t-b)/zoom);
			t = midy+((t-b)/zoom);
		}
		else if(ev.mouse.button == 2)
		{
			l = -2.5;
			r = 2.5;
			b = -2.5;
			t = 2.5;
		}
		
		julia(table, iter, cx, cy, l, r, b, t);
		for(int i = 0; i < 512; i++)
		{
			for(int j = 0; j < 512; j++)
			{
				red = table[k];
				red = red - '0';
				green = table[k+1];
				green = green - '0';
				blue = table[k+2];
				blue = blue - '0';
				al_put_pixel(j, i,al_map_rgb(red, green, blue));
				k=k+3;
			}
  		}
  		k = 0;
		
	}

	al_flip_display();
  }

  free(table);
  al_destroy_event_queue(event_queue);
  al_destroy_display(display);

  return 0;
}
