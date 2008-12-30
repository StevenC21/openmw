/*
  OpenMW - The completely unofficial reimplementation of Morrowind
  Copyright (C) 2008  Nicolay Korslund
  Email: < korslund@gmail.com >
  WWW: http://openmw.snaptoad.com/

  This file (object.d) is part of the OpenMW package.

  OpenMW is distributed as free software: you can redistribute it
  and/or modify it under the terms of the GNU General Public License
  version 3, as published by the Free Software Foundation.

  This program is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  version 3 along with this program. If not, see
  http://www.gnu.org/licenses/ .

 */

module mscripts.object;

import monster.monster;
import std.stdio;
import std.date;
import core.resource : rnd;
import core.config;
import sound.music;

// Set up the base Monster classes we need in OpenMW
void initMonsterScripts()
{
  // Add the script directories
  vm.addPath("mscripts/");
  vm.addPath("mscripts/gameobjects/");
  vm.addPath("mscripts/sound/");

  // Make sure the Object class is loaded
  auto mc = new MonsterClass("Object", "object.mn");

  // Get the Config singleton object
  config.mo = (new MonsterClass("Config")).getSing();

  // Bind various functions
  mc.bind("print", { print(); });
  mc.bind("randInt",
  { stack.pushInt(rnd.randInt
    (stack.popInt,stack.popInt));});
  mc.bind("sleep", new IdleSleep);

  // Load and run the test script
  mc = new MonsterClass("Test");
  mc.createObject().call("test");
}

// Write a message to screen
void print()
{
  AIndex[] args = stack.popAArray();

  foreach(AIndex ind; args)
    writef("%s ", arrays.getRef(ind).carr);
  writefln();
}

// Sleep a given amount of time. Currently uses the system clock, but
// will later be optimized to use the already existing timing
// information from OGRE.
class IdleSleep : IdleFunction
{
  long getLong(MonsterObject *mo)
    { return *(cast(long*)mo.extra); }
  void setLong(MonsterObject *mo, long l)
    { *(cast(long*)mo.extra) = l; }

 override:
  bool initiate(MonsterObject *mo)
    {
      // Get the parameter
      float secs = stack.popFloat;

      // Get current time
      long newTime = getUTCtime();

      // Calculate when we should return
      newTime += cast(long)secs*TicksPerSecond;

      // Store it
      if(mo.extra == null) mo.extra = new long;
      setLong(mo, newTime);

      // Schedule us
      return true;
    }

  bool hasFinished(MonsterObject *mo)
    {
      // Is it time?
      return getUTCtime() >= getLong(mo);
    }
}
