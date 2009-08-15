class Tracking
{
  //do we really need to keep track of how many players? or can we just do that automatically by changing the size of the player array?
  int numberOfPlayers = 8;

  //this is which players color to set
  int whatPlayer;

  PVector testColor;

  //this holds a list of player objects
  ArrayList players;

  //the sketch
  PApplet parent;

  //current frame of video
  PImage testImg;

  //make sure that the boundries are somewhere near the value of the actual color
  int threshold = 50;

  Tracking(PApplet app)
  {
    parent = app;
    players = new ArrayList();  // Create an empty ArrayList
    for (int i = 0; i < numberOfPlayers ; i++) players.add(new Player());
    testColor = new PVector(0,0,0); //Create PVector for testing color distance
  }

  void update(PImage t)
  {
    testImg = t;
    ////////////////////////////////////////
    // Loop through each active player's neighborhood
    // find the edges from the last known x,y of the player 
    // find the middle point of the edges
    // draw the new location
    ////////////////////////////////////////
    for(int i=0;i<players.size();i++)
    {
      Player player = (Player) players.get(i);

      if(player.active)
      {
//        println("this is players colors");
//        println(player.targetColor.x+" : "+player.targetColor.y+" : "+player.targetColor.y);
//        println();
        //draw the last known location
        fill(255,0,0);
        ellipse(player.lastLoc.x, player.lastLoc.y, 10, 10);

        //reset the benchmarks player bounding box
        player.mainPixelBenchmark = 500;
        player.topEdgeBenchmark=500;
        player.leftEdgeBenchmark=500;
        player.rightEdgeBenchmark=500;
        player.bottomEdgeBenchmark=500;

        //reset the bounding box for the player
        player.leftEdge = 0;
        player.rightEdge = 0;
        player.topEdge = 0;
        player.bottomEdge = 0;
        
        
        int startX = (int)player.lastLoc.x - (player.neighborhood/2);
        int startY = (int)player.lastLoc.y - (player.neighborhood/2);
        
        for(int x = startX; x < startX + player.neighborhood; x++)
        {
          for(int y = startY; y < startY + player.neighborhood; y++)
          {
            color mainPixelColor = testImg.get(x,y);
            float d = colorDistance(mainPixelColor,player.targetColor);
            if(d < threshold && d < player.mainPixelBenchmark)
            {
              player.mainPixelBenchmark = d;
              player.tmpLoc.x = x;
              player.tmpLoc.y = y;
            }
          }
        }

        //////////////////////////////
        //take the last known location and find the left and top edge of player bounding box
        //////////////////////////////
        for(int j = player.playerSize; j > 0; j--)
        {
          //testing for top edge
          color topEdgeColor = testImg.get((int)player.tmpLoc.x, (int)player.tmpLoc.y-j);

          //get the distance between the current color and the players target color
          float d = colorDistance(topEdgeColor,player.targetColor);
          if(d < threshold && d < player.topEdgeBenchmark)
          {
            player.topEdgeBenchmark = d;
            int y = (int)player.tmpLoc.y;
            player.topEdge = (y-j);
          }

          //testing for left edge
          color leftEdgeColor = testImg.get((int)player.tmpLoc.x-j, (int)player.tmpLoc.y);

          //get the distance between the current color and the players target color
          d = colorDistance(leftEdgeColor,player.targetColor);
          if(d < threshold && d < player.topEdgeBenchmark)
          {
            player.topEdgeBenchmark = d;
            int x = (int)player.tmpLoc.x;
            player.leftEdge = (x-j);
          }
        }

        ///////////////////////////////////////
        //now that we have the top and left edge
        //lets get the right and bottom edge
        ///////////////////////////////////////
        for(int j = 0; j < player.playerSize; j++)
        {
          //testing for right edge
          color rightEdgeColor = testImg.get(player.leftEdge+j, player.topEdge);       
          //get the distance between the current color and the players target color
          float d = colorDistance(rightEdgeColor, player.targetColor);
          if(d < threshold && d < player.rightEdgeBenchmark)
          {
            player.rightEdgeBenchmark = d;
            player.rightEdge = player.leftEdge+j;
          }

          //testing for bottom edge
          color bottomEdgeColor = testImg.get(player.leftEdge, player.topEdge+j);
          //get the distance between the current color and the players target color
          d = colorDistance(bottomEdgeColor,player.targetColor);
          if(d < threshold && d < player.bottomEdgeBenchmark)
          {
            player.bottomEdgeBenchmark = d;
            player.bottomEdge = player.topEdge+j;
          }
        }

        //now that we have the bounding box
        //assign the new players x,y to the center of the bounding box
        player.currentLoc.x = player.leftEdge + ((player.rightEdge - player.leftEdge)/2);
        player.currentLoc.y = player.topEdge + ((player.bottomEdge - player.topEdge)/2);

        //keep store the location for the next loop
        player.lastLoc.x = player.currentLoc.x;
        player.lastLoc.y = player.currentLoc.y;

        //draw the new location
        fill(0,255,0);
        ellipse(player.currentLoc.x, player.currentLoc.y, 10, 10);

      }
    }
  }

  void mousePressed() 
  {
    // Save color where the mouse is clicked in trackColor variable
    if(mouseX > 0 && mouseX < 640 && mouseY > 0 && mouseY < 480)
    {
      Player player = (Player)players.get(whatPlayer);
      player.init(mouseX,mouseY,testImg.get(mouseX,mouseY));
      //println(red(testImg.get(mouseX,mouseY))+" : "+green(testImg.get(mouseX,mouseY))+" : "+blue(testImg.get(mouseX,mouseY)));
    }

  }

  void keyPressed()
  {
    whatPlayer = int(key)-49;
  }


  float colorDistance(color tC, PVector pC)
  {
    //load the current color into the testColor vector
    testColor.x = red(tC);
    testColor.y = green(tC);
    testColor.z = blue(tC);
    return PVector.dist(testColor, pC);
  }
}
























