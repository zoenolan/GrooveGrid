// GrooveGrid

Maxim soundsystem;

// base class for user interface elements
class Widget
{
  PVector mPosition;
  PVector mExtents; 
 
  Widget(int startX,      int startY, 
         int buttonWidth, int buttonHeight)
  {
    // start position
    mPosition   = new PVector(startX, startY);  

    // Width and height
    mExtents    = new PVector(buttonWidth, buttonHeight);
  }
  
  boolean IsInsideBoundingBox(int pointX, int pointY)
  {
    if (pointX > mPosition.x && pointX < (mPosition.x + mExtents.x) &&
        pointY > mPosition.y && pointY < (mPosition.y + mExtents.y))
    {
      return (true);
    }
    else
    {
      return (false);
    }    
  }
}

// Base button class, adds an on/off state
class Button extends Widget
{
  boolean mbState; 
 
  Button(int startX,      int startY, 
         int buttonWidth, int buttonHeight, 
         boolean bDefaultState)
  {
    super(startX, startY, buttonWidth, buttonHeight);    
     
    // Current state 
    mbState     = bDefaultState; 
  }
       
  boolean GetState()
  {
    return (mbState);
  }
  
  void TestForClick(int pointerX, int pointerY)
  {
    if (IsInsideBoundingBox(pointerX, pointerY))
    {
      mbState = !mbState;
    }
  }
}

// Radio button adds a draw method
class RadioButton extends Button
{
  color   mColour; 
  
  RadioButton(int startX,      int startY, 
             int buttonWidth, int buttonHeight, 
             color colour,
             boolean bDefaultState)
  {
    super(startX, startY, buttonWidth, buttonHeight, bDefaultState);    

    mColour = colour;   
  }

  void Draw()
  {
    pushStyle();

    if (mbState)
    {
      fill(mColour);      
    }
    else
    {
      noFill();
      stroke(mColour);      
    }

    rect(mPosition.x,  mPosition.y, mExtents.x, mExtents.y);
    popStyle();    
  } 
  
  PVector GetCentre()
  {
    PVector centre = new PVector(mPosition.x + (mExtents.x / 2), mPosition.y + (mExtents.y / 2));
    return (centre);
  }
}

// Text button adds on/off colours and text labels
class TextButton extends Button
{
  String  mLabels[];
  color   mButtonColours[]; 
  color   mTextColours[]; 
  
  TextButton(int startX,      int startY, 
             int buttonWidth, int buttonHeight, 
             String activeLabel,   color activeButtonColour,   color activeTextColour,
             String inactiveLabel, color inactiveButtonColour, color inactiveTextColour,
             boolean bDefaultState)
  {
    super(startX, startY, buttonWidth, buttonHeight, bDefaultState);    
    
    mLabels           = new String[2];  
    mButtonColours    = new color[2];
    mTextColours      = new color[2];
    
    // Deselected state
    mLabels[0]        = inactiveLabel;
    mButtonColours[0] = inactiveButtonColour;
    mTextColours[0]   = inactiveTextColour;
    
    // Selected state     
    mLabels[1]        = activeLabel;
    mButtonColours[1] = activeButtonColour;
    mTextColours[1]   = activeTextColour;   
  }

  void Draw()
  {
    pushStyle();

    // Button
    fill(mButtonColours[int(mbState)]);
    rect(mPosition.x,  mPosition.y, mExtents.x, mExtents.y);

    // Text label
    fill(mTextColours[int(mbState)]);
    textAlign(CENTER, CENTER);
    text(mLabels[int(mbState)], mPosition.x + 0.5*mExtents.x, mPosition.y + 0.5* mExtents.y);
    
    popStyle();    
  } 
}

// Grid creates and draw a button grid
class Grid extends Widget
{
  int            mSteps;
  int            mInstruments;  
 
  RadioButton[][] mGrid; 
  
  Grid(int startX, int startY, 
       int Width,  int Height, 
       int steps,  int instruments,
       color buttonColour,
       int buttonSize)
  {
    super(startX, startY, Width, Height); 
    
    mSteps       = steps;
    mInstruments = instruments;

    int borderPixelsX = (Width - (buttonSize * steps)) / steps;
    int borderPixelsY = (Height - (buttonSize * instruments)) / instruments;
    
    mGrid = new RadioButton[steps][instruments];
    for (int i = 0; i < steps; i++)
    {
      for (int j = 0; j < instruments; j++)
      {
        // The first button starts at startX/Y + half a border
        // each button after that starts the button size + a full border after the end of the last button
        int buttonStartX = startX + (borderPixelsX/2) + ((buttonSize  + borderPixelsX) * i);
        int buttonStartY = startY + (borderPixelsY/2) + ((buttonSize + borderPixelsY) * j);
        
        mGrid[i][j] = new RadioButton(buttonStartX, buttonStartY, 
                                      buttonSize,  buttonSize, 
                                      buttonColour,
                                      false);
      }
    }  
  }
  
  void Draw()
  {
    for (int i = 0; i < mSteps; i++)
    {
      for (int j = 0; j < mInstruments; j++)
      {
        mGrid[i][j].Draw(); 
      }
    }
  }  

  void TestForClick(int pointerX, int pointerY)
  {
    if (IsInsideBoundingBox(pointerX, pointerY))
    {      
      for (int i = 0; i < mSteps; i++)
      {
        for (int j = 0; j < mInstruments; j++)
        {
          mGrid[i][j].TestForClick(pointerX, pointerY);
        }
      }
    }
  }

  boolean GetState(int x, int y)
  {
      return (mGrid[x][y].GetState());
  } 
 
  PVector GetButtonCentre(int x, int y)
  {
      return (mGrid[x][y].GetCentre());
  }  
}

class Background extends Widget
{
  int   mSteps;
  int   mCurrentStep;
  color mStepColour;  
  
  Background(int startX, int startY, 
             int Width,  int Height,
             int steps,
             color stepColour)
  {
    super(startX, startY, Width, Height); 
    
    mSteps       = steps;
    mCurrentStep = 0;
    
    mStepColour  = stepColour;
  }
  
  void Draw()
  {
    pushStyle();

    fill(mStepColour);
    int stepWidth = int(mExtents.x / mSteps);
    int startX = int(mPosition.x + (stepWidth * mCurrentStep));
    rect(startX,  mPosition.y, stepWidth, mExtents.y);
   
    popStyle(); 
  }   
  
  void SetStep(int step)
  {
    mCurrentStep = step;  
  }
}

class Slider extends Widget
{
  color  mOffColour;
  color  mOnColour;
  color  mLineColour;
  String mLabel;
  float  mLevel;
  
  Slider(int startX, int startY, 
         int Width,  int Height,
         color offColour, color onColour,
         color lineColour,
         String label,
         float position)
  {
    super(startX, startY, Width, Height); 
    
    mOffColour  = offColour;
    mOnColour   = onColour;
    mLineColour = lineColour;
    mLabel      = label;
    mLevel      = min( 1, max(position, 0));
  }
  
  void Draw()
  {
    pushStyle();

    fill(lerpColor(mOffColour, mOnColour, mLevel));
    rect(mPosition.x, mPosition.y, mExtents.x, mExtents.y);

    fill(mLineColour);   
    rect(mPosition.x + (mLevel * mExtents.x), mPosition.y, 2, mExtents.y);

    // Text label
    fill(mLineColour);
    textAlign(CENTER, CENTER);
    text(mLabel, mPosition.x + 0.5*mExtents.x, mPosition.y + 0.5* mExtents.y);

    popStyle();   
  }    
  
  void TestForClick(int pointerX, int pointerY)
  {
    if (IsInsideBoundingBox(pointerX, pointerY))
    { 
      mLevel = (pointerX - mPosition.x)/ mExtents.x;    
    }
  }  
  
  float GetLevel()
  {
    return (mLevel);  
  }
}

class Particle
{
  PVector mPosition;
  PVector mDirection;

  color   mStartColour;
  color   mEndColour;

  float   mStartSize;
  float   mEndSize;
 
  int     mLifetime;
  int     mAge;
 
  Particle()
  {
    mLifetime = 0;   
  }
  
  Particle(PVector position,    PVector direction,
           color   startColour, color   endColour,
           float   startSize,   float   endSize,
           int     lifetime)
  {
    mPosition    = position;
    mDirection   = direction;

    mStartColour = startColour;
    mEndColour   = endColour;

    mStartSize   = startSize;
    mEndSize     = endSize;
 
    mLifetime    = lifetime;    
    mAge         = 0;
  }
 
  boolean IsDead()
  {
     return (mLifetime == 0);
  } 
  
  int GetAge()
  {
      return (mAge);  
  }
  
  void Update(float attractor)
  {
    if (!IsDead())
    {
      mAge++;
    
      if (mAge >= mLifetime)
      {
        mLifetime = 0;
      } 
      else
      {
        // try to move toward the centre of mass
        float agedSpeed = mLifetime + mAge; 
        float directionToAttractor = (attractor - mPosition.y) / agedSpeed;
        
        PVector yAxisDirection = new PVector(0, directionToAttractor);
        mDirection.add(yAxisDirection);
         
        mPosition.add(mDirection);

        // handle wrapping around the X axis
        if (mPosition.x >= width)
        {
          PVector offset = new PVector(width, 0);
          mPosition.sub(offset);
        }
        
        // Handle bouncing off the top and bottom of the screen
        if ((mPosition.y < 0) || (mPosition.y > height))
        {
          mDirection = new PVector(mDirection.x, -mDirection.y);
        }
      } 
    }
  }
  
  void Draw()
  {
    if (!IsDead())
    {
      pushStyle();
      
      float lerpFactor = float(mAge)/float(mLifetime);     
      fill(lerpColor(mStartColour, mEndColour, lerpFactor));
      
      noStroke();
      
      float currentSize = lerp (mStartSize, mEndSize, lerpFactor);
      ellipse(mPosition.x, mPosition.y, currentSize, currentSize);

      // handle the cases where the particle is partly off one side off the screen
      if ((mPosition.x + (currentSize/2)) >= width)
      {
        ellipse(mPosition.x - width, mPosition.y, currentSize, currentSize);        
      }
      else if ((mPosition.x - (currentSize/2)) < 0)
      {
        ellipse(mPosition.x + width, mPosition.y, currentSize, currentSize);         
      }

      popStyle();           
    } 
  }

}

class ParticleSystem
{
  float      mTarget;
  Particle[] mParticles;
  
  ParticleSystem(int MaxParticles)
  {
      mParticles = new Particle[MaxParticles];
      for (int i = 0; i < mParticles.length; i++)
      {
        mParticles[i] = new Particle();
      }       
      
  } 
 
  void Add(PVector position,    PVector direction,
           color   startColour, color   endColour,
           float   startSize,   float   endSize,
           int     lifetime)
  {
    // Find a free particle
    boolean bFound =  false;
    int i = 0;
    while (!bFound && (i < mParticles.length))
    {
      if (mParticles[i].IsDead())
      {
        bFound = true;  
      }
      else
      {
        i++;  
      }
    }
    
    // If we didn't find a free particle find the oldest
    if (!bFound)
    {
      int oldestParticle = 0;
      int oldestAge      = mParticles[0].GetAge(); 
      for (i = 1; i < mParticles.length; i++)
      {
        if (oldestAge < mParticles[i].GetAge())
        {
          oldestParticle = i;
          oldestAge      = mParticles[i].GetAge(); 
        }
      }        
    }
    
    // At this point we have a free particle or the oldest to reuse
    mParticles[i] = new Particle (position,    direction,
                                  startColour, endColour,
                                  startSize,   endSize,
                                  lifetime);
  }
  
  void SetTarget(float attractor)
  {
    mTarget = attractor;
  }
  
  void Update()
  {  
    for (int i = 0; i < mParticles.length; i++)
    { 
      if (!mParticles[i].IsDead())
      {
        mParticles[i].Update(mTarget);
      }
    }    
  }
  
  void Draw()
  {
    for (int i = 0; i < mParticles.length; i++)
    {
      mParticles[i].Draw();
    }
  }
}

class AudioEngine
{
  AudioPlayer mSamples[]; 
  
  AudioEngine(int samples)
  {
    mSamples          = new AudioPlayer[samples];
    String stub       = "sample";
    String extension  = ".wav";
    
    for (int i = 0; i < samples; i++)
    {
      mSamples[i] = soundsystem.loadFile(stub+i+extension);
      mSamples[i].setLooping(false);
      mSamples[i].volume(1);      
    }
  }
  
  void Play(int sample)
  {
    mSamples[sample].cue(0);
    mSamples[sample].play();
  }
}

class Sequencer extends Widget
{  
  int            mSteps;
  int            mInstruments;  

  boolean        mbVisible;
 
  color          mBackgroundColour;
  Background     mBackground;
  ParticleSystem mParticleSystem;
  Grid           mGrid; 
  Slider         mTempo;
  
  AudioEngine    mAudioSystem;
  
  int            mClock;
  int            mCurrentStep;
  int            mCurrentTempo; 
  
  color          mParticleStartColour;
  color          mParticleEndColours[];
  float          mParticleStartSize;
  float          mParticleEndSize;
  
  Sequencer(int startX, int startY, 
            int Width,  int Height, 
            int steps,  int instruments,
            int tempoBarHeight,
            color backgroundColour,
            color stepColour,
            color buttonColour,
            int buttonSize,
            color sliderOff, color sliderOn, color SliderHighlight,
            color particleStartColour, color particleEndColours[],
            float particleStartSize, float particleEndSize,
            boolean bVisble)
  {
    super(startX, startY, Width, Height); 
    
    mSteps            = steps;
    mInstruments      = instruments;
    
    mClock            = 0;
    mCurrentStep      = 0;

    // interface    
    mBackgroundColour = backgroundColour;
    
    SetVisiblity(bVisble);

    mBackground        = new Background(startX, startY, Width, Height, mSteps, stepColour);
    mParticleSystem    = new ParticleSystem(steps * instruments);
    mGrid              = new Grid(startX, startY, Width, Height - tempoBarHeight, steps, instruments, buttonColour, buttonSize);  
    mTempo             = new Slider(startX, startY + Height - tempoBarHeight, Width, tempoBarHeight,
                                    sliderOff, sliderOn, SliderHighlight,
                                    "Tempo", 0.5);
                                    
    // audio                                
    mAudioSystem       = new AudioEngine(instruments);

    // set the particle parameters
    mParticleStartColour = particleStartColour;
    mParticleEndColours  = new color[instruments];
    for (int i = 0; i < instruments; i++)
    {
      mParticleEndColours[i] = particleEndColours[i]; 
    }
    mParticleStartSize   = particleStartSize;
    mParticleEndSize     = particleEndSize;    
  }
  
  void SetVisiblity(boolean bVisble)
  {
    mbVisible = bVisble;  
  }
  
  void Draw()
  {
    pushStyle();

    // Background
    fill(mBackgroundColour);
    rect(mPosition.x,  mPosition.y, mExtents.x, mExtents.y);
   
    popStyle(); 

    if (mbVisible)
    {    
      mBackground.Draw();
    }
    
    mParticleSystem.Draw();
    
    if (mbVisible)
    {
      mGrid.Draw();
      mTempo.Draw();
    }  
  }  

  void TestForClick(int pointerX, int pointerY)
  {
    if (mbVisible)
    {    
      if (IsInsideBoundingBox(pointerX, pointerY))
      {      
        mGrid.TestForClick(pointerX, pointerY);
        mTempo.TestForClick(pointerX, pointerY);
      }
    }  
  } 

  void TestForDrag(int pointerX, int pointerY)
  {
    if (mbVisible)
    {    
      if (IsInsideBoundingBox(pointerX, pointerY))
      {      
        mTempo.TestForClick(pointerX, pointerY);
      }
    }  
  }
  
  void Clock()
  {  
    mCurrentTempo = int(lerp(1, 10, 1 - mTempo.GetLevel()));  
    mClock++;
           
    if (mClock % mCurrentTempo == 0)
    { 
      mBackground.SetStep(mCurrentStep);      
    
      // for each Instrument in the current column see if we need to trigger an event    
      float attractors[] = new float[mInstruments];
      int attractorsIndex = 0;
   
      for (int i = 0; i < mInstruments; i++)
      {
        if (mGrid.GetState(mCurrentStep, i))
        {
            // Add the particle
            float distance    = (mGrid.GetButtonCentre(1, 0).x - mGrid.GetButtonCentre(0, 0).x)/mCurrentTempo;
            float lifetime    = (mExtents.x - mPosition.x) / distance; 
            PVector direction = new PVector(distance, 0);
            mParticleSystem.Add(mGrid.GetButtonCentre(mCurrentStep, i), direction, 
                                mParticleStartColour, mParticleEndColours[i], 
                                mParticleStartSize, mParticleEndSize, int(lifetime));
            
            // Add this point to the list of Attractors
            attractors[attractorsIndex] = mGrid.GetButtonCentre(mCurrentStep, i).y;
            attractorsIndex++;
             
            // trigger the sound
            mAudioSystem.Play(i);          
        }     
      }
      
      mCurrentStep++;
      if (mCurrentStep >= mSteps)
      {
        mCurrentStep = 0;
      }

      // Calculate the mean position of all the active buttons    
      float meanCentre = 0;
  
      // Guard against divde by zero
      if (attractorsIndex > 0)
      {
        for (int i = 0; i < attractorsIndex; i++)
        {
           meanCentre += attractors[i]; 
        }
        
        meanCentre /= attractorsIndex;
         
        mParticleSystem.SetTarget(meanCentre);
      }
    }     
  
    mParticleSystem.Update();  
  }
}

TextButton controlPanel;
Sequencer  sequencer;

void setup()
{
  // Screen size comstants
  int screenWidth           = 800;
  int screenHeight          = 600;

  // Sequencer options
  int sounds                =  8;
  int steps                 = 40;

  // layout and colours
  color backgroundColour    = color(255, 255, 255);
  
  color stepColour          = color(200, 200, 255);
  color buttonAndTextColour = color(32, 32, 32);
  
  color sliderOff           = color(0, 0, 100);
  color sliderOn            = color(164, 0, 164); 

  color startColour = color(255, 255, 255, 255);

  color endColours[] = new color[sounds];
  endColours[0]      = color(255, 0,   0,   0);
  endColours[1]      = color(255, 255, 0,   0);
  endColours[2]      = color(255, 0,   255, 0);
  endColours[3]      = color(0,   0,   0,   0);
  endColours[4]      = color(0,   255, 0,   0);
  endColours[5]      = color(0,   255, 255, 0);
  endColours[6]      = color(0,   0,   255, 0);
  endColours[7]      = color(128, 255, 0,   0); 

  float startSize    = 4;
  float endSize      = 350;  
 
  int controlHeight  = 16;
  
  // Set the Window size and framerate
  size(800, 600);
  frameRate(30);    

  soundsystem = new Maxim(this);
  
  controlPanel = new TextButton(0, 0, 
                                screenWidth, controlHeight, 
                                "Hide sequencer controls", color(127,127,127), backgroundColour,
                                "Show sequencer controls", color(127,127,127), buttonAndTextColour,
                                true);  
  
  sequencer = new Sequencer(0, controlHeight, 
                            screenWidth, screenHeight - controlHeight,
                            steps, sounds,
                            controlHeight,
                            backgroundColour,
                            stepColour,
                            buttonAndTextColour, 12,
                            sliderOff, sliderOn, buttonAndTextColour,
                            startColour, endColours,
                            startSize, endSize,
                            controlPanel.GetState());                           
}

void draw()
{
  // update the status
  sequencer.SetVisiblity(controlPanel.GetState());
  sequencer.Clock();
  
  // draw the interface
  controlPanel.Draw();
  sequencer.Draw(); 
}


void mousePressed()
{
  controlPanel.TestForClick(mouseX, mouseY);
  sequencer.TestForClick(mouseX, mouseY);
}

void mouseDragged()
{
  sequencer.TestForDrag(mouseX, mouseY);
}

