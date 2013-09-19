// $Id: DotChart.cpp,v 1.1.1.1 2013/01/06 16:54:18 braunefe Exp $
/***********************************************************************
 Moses - factored phrase-based language decoder
 Copyright (C) 2010 Hieu Hoang

 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.

 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 ***********************************************************************/

#include "DotChart.h"

namespace Moses
{

std::ostream &operator<<(std::ostream &out, const DottedRule &rule)
{
  if (!rule.IsRoot()) {
    out << rule.GetWordsRange() << "=" << rule.GetSourceWord() << " ";
    if (!rule.m_prev->IsRoot()) {
      out << " " << *rule.m_prev;
    }
  }
  return out;
}

}
