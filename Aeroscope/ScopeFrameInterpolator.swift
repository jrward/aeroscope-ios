//
//  ScopeFrameInterpolator.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 7/6/16.
//  Copyright © 2016 Jonathan Ward. All rights reserved.
//

import Foundation
import Accelerate

enum InterpFactor : Int {
    case x1 = 1
    case x2 = 2
    case x5 = 5
    case x10 = 10
    case x20 = 20
}

class ScopeFrameInterpolator {
    


    
    fileprivate let kernelLength : Int = 60
    fileprivate let kernelFactor : Int = 10
    
    let sinc10_blackman3 : [Float] = [0.0,
                              -2.511818586643577e-13,
                              -3.138182540064532e-11,
                              -5.080203576776812e-10,
                              -3.485365572616199e-09,
                              -1.4603503944969047e-08,
                              -4.355608579763244e-08,
                              -9.862211003677056e-08,
                              -1.6932076952892953e-07,
                              -1.9220397336270583e-07,
                              0.0,
                              7.348417015995993e-07,
                              2.5346764947600424e-06,
                              6.0821899725727455e-06,
                              1.2053442889467828e-05,
                              2.075181506319221e-05,
                              3.1499289591190666e-05,
                              4.180334856136815e-05,
                              4.6425188235063994e-05,
                              3.662223633982181e-05,
                              0.0,
                              -7.846305021650452e-05,
                              -0.00021362738494725211,
                              -0.0004152048900610438,
                              -0.0006805363676983093,
                              -0.0009857710139336154,
                              -0.0012769816313323965,
                              -0.0014637263638711737,
                              -0.0014183791888568635,
                              -0.0009848740499833054,
                              0.0,
                              0.0016712214606654401,
                              0.0040873377701510375,
                              0.007174489907836084,
                              0.010671943201342555,
                              0.0140922337007362,
                              0.01671136142811516,
                              0.01760416283261713,
                              0.015736207103127082,
                              0.010115959414109983,
                              0.0,
                              -0.01486885367250851,
                              -0.03402340651948355,
                              -0.05607659675868045,
                              -0.07861537456575043,
                              -0.098226744450186,
                              -0.11068582573770992,
                              -0.11131441750500709,
                              -0.09549119535838586,
                              -0.05926541210799722,
                              0.0,
                              0.08304736198052799,
                              0.1883008750902585,
                              0.31168515482268183,
                              0.44674287139441177,
                              0.5850691581786929,
                              0.7170340672124178,
                              0.8327185755095964,
                              0.9229524017594922,
                              0.9803200919702525,
                              1.0,
                              0.9803200919702523,
                              0.9229524017594916,
                              0.8327185755095957,
                              0.7170340672124168,
                              0.585069158178693,
                              0.4467428713944107,
                              0.31168515482268094,
                              0.18830087509025753,
                              0.08304736198052713,
                              0.0,
                              -0.05926541210799773,
                              -0.09549119535838614,
                              -0.11131441750500737,
                              -0.11068582573771005,
                              -0.09822674445018609,
                              -0.07861537456575048,
                              -0.056076596758680555,
                              -0.03402340651948338,
                              -0.014868853672508382,
                              0.0,
                              0.010115959414109988,
                              0.01573620710312721,
                              0.017604162832617145,
                              0.016711361428115173,
                              0.0140922337007362,
                              0.01067194320134257,
                              0.00717448990783607,
                              0.004087337770151043,
                              0.0016712214606654295,
                              0.0,
                              -0.0009848740499833043,
                              -0.0014183791888568733,
                              -0.0014637263638711772,
                              -0.0012769816313323965,
                              -0.0009857710139336128,
                              -0.0006805363676983084,
                              -0.0004152048900610446,
                              -0.00021362738494725244,
                              -7.846305021650416e-05,
                              0.0,
                              3.6622236339822776e-05,
                              4.642518823506437e-05,
                              4.180334856136851e-05,
                              3.1499289591190645e-05,
                              2.0751815063192257e-05,
                              1.2053442889467804e-05,
                              6.082189972572741e-06,
                              2.5346764947600403e-06,
                              7.348417015996048e-07,
                              0.0,
                              -1.9220397336271052e-07,
                              -1.6932076952892866e-07,
                              -9.862211003677209e-08,
                              -4.3556085797632246e-08,
                              -1.4603503944969047e-08,
                              -3.4853655726162662e-09,
                              -5.080203576777096e-10,
                              -3.138182540064517e-11,
                              -2.5118185866431535e-13,
                              0.0]
    
    
    fileprivate func convolve(signal: Samples, kernel k: [Float], stride: Int) -> Samples {
        assert(signal.count > (k.count/stride))
        
        var resultSamples = signal
        //let resultSize = signal.count + (k.count/stride) - 1
        let resultSize = signal.count + ((k.count - 1)/stride)

        var result = [Float](repeating: 0, count: resultSize)
        let kStart = UnsafePointer<Float>(k)
        //let xPad = repeatElement(Float(0.0), count: (k.count/stride)-1)
        let signalPad = repeatElement(Float(0.0), count: (k.count/stride)/2)
        let signalPadded = signalPad + signal.raw + signalPad
        vDSP_conv(signalPadded, 1, kStart, vDSP_Stride(stride), &result, 1, vDSP_Length(resultSize), vDSP_Length(k.count/stride))
        
        
        resultSamples.raw = result
        return resultSamples
    }

    
    fileprivate func upsample(_ frame: Samples, factor: Int) -> Samples {
        var ret = Samples()
        for el in frame.data {
            ret.append(sample: el)
            for _ in 1..<factor {
                ret.append(0.0)
            }
        }
        return ret
    }
    
    fileprivate func extend(_ frame: Samples, num: Int) -> Samples {
        var ret = Samples()
        ret = frame
        for _ in 0..<num {
            ret.append(ret.data.last!.value)
        }
        for _ in 0..<num {
            ret.insert(ret.data[0].value, at: 0)
        }
        return ret
    }
    
    func interpolate (_ frame: Samples, factor: InterpFactor) -> Samples {
        var myframe : Samples
        var ret : Samples
        //let extendSize = max( (kernel_length / kernel_factor), kernel_length/)
        
        let kernelStride : Int = kernelFactor/factor.rawValue
        let extendSize : Int = kernelLength/kernelStride

        myframe = extend(frame, num: extendSize/factor.rawValue)
        myframe = upsample(myframe, factor: factor.rawValue)
     
//        let kernel : [Float]
//        switch factor {
//        case 10: kernel = mysincw10
//        case 5: kernel = mysincw5
//        case 2: kernel = mysincw2
//        default: kernel = mysincw10
//        }
        
        ret = convolve(signal: myframe, kernel: sinc10_blackman3, stride: kernelStride)
        
        //ret = ret.map({min(max($0,0),255)})

        let returnedSamples : [Sample]
        let dataSizeToCut : Int
        
        //TODO: Recorrect the array alignment of these!
        switch factor {
        case .x10:  returnedSamples = Array(ret.data[(extendSize)..<(ret.count - extendSize)])
        case .x5:  returnedSamples = Array(ret.data[(extendSize)..<(ret.count - extendSize)])
        case .x2:  returnedSamples = Array(ret.data[(extendSize)..<(ret.count - extendSize)])
        default: returnedSamples = frame.data
        }

        //returnedSamples = Array(ret.data[(extendSize)..<(ret.count - extendSize)])
        
        return Samples(samples: returnedSamples)
    }
}
