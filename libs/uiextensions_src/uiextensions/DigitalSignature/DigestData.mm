/**
 * Copyright (C) 2003-2017, Foxit Software Inc..
 * All Rights Reserved.
 *
 * http://www.foxitsoftware.com
 *
 * The following code is copyrighted and is the proprietary of Foxit Software Inc.. It is not allowed to
 * distribute any parts of Foxit Mobile PDF SDK to third party or public without permission unless an agreement
 * is signed between Foxit Software Inc. and customers to explicitly grant customers permissions.
 * Review legal.txt for additional license and legal information.
 */

#import "DigestData.h"

//Construct and Destruct functions.

CFSCRT_DigestContext::CFSCRT_DigestContext()
{
    m_pDigestData = NULL;
}

CFSCRT_DigestContext::~CFSCRT_DigestContext()
{
    if (NULL!=m_pDigestData)
    {
        delete m_pDigestData;
        m_pDigestData=NULL;
    }
}

//Initialize function.
void CFSCRT_DigestContext::Initialize()
{
    
}

//Finalize function.
void CFSCRT_DigestContext::Release()
{
    
}

//Set variable m_pDigestData.
BOOL CFSCRT_DigestContext::SetData(void* file, const unsigned int* byteRangeArray, unsigned int sizeofArray)
{
    if (NULL != m_pDigestData)
    {
        delete m_pDigestData;
        m_pDigestData = NULL;
    }
    
    FSCRT_DigestData* pData = new FSCRT_DigestData;
    pData->m_file = file;
    pData->m_pByteRangeArray = byteRangeArray;
    pData->m_sizeofArray = sizeofArray;
    
    m_pDigestData = pData;
    
    return TRUE;
}

//Get variable m_pDigestData.
BOOL CFSCRT_DigestContext::GetData(FSCRT_DigestData*& data)
{
    data = m_pDigestData;
    return TRUE;
}


