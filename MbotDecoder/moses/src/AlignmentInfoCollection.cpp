/***********************************************************************
 Moses - statistical machine translation system
 Copyright (C) 2006-2011 University of Edinburgh
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

#include "AlignmentInfoCollection.h"

using namespace std;

namespace Moses
{

AlignmentInfoCollection AlignmentInfoCollection::s_instance;

AlignmentInfoCollection::AlignmentInfoCollection()
{
  std::set<std::pair<size_t,size_t> > pairs;
  m_emptyAlignmentInfo = Add(pairs);
}

const AlignmentInfo &AlignmentInfoCollection::GetEmptyAlignmentInfo() const
{
  return *m_emptyAlignmentInfo;
}


const AlignmentInfo *AlignmentInfoCollection::Add(
    const std::set<std::pair<size_t,size_t> > &pairs)
{
    std::pair<AlignmentInfoSet::iterator, bool> ret =
    m_collection.insert(AlignmentInfo(pairs));
    return &(*ret.first);
}

}
